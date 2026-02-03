import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordModel.dart';
import 'package:quizeapp/models/RootWordModel.dart';
import 'package:quizeapp/services/DictionaryWordsService.dart';
import 'package:quizeapp/services/RootWordsService.dart';
import 'package:quizeapp/services/QuranDatabaseService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/widgets/urdu_keyboard.dart';

class DictionaryWordsView extends StatefulWidget {
  const DictionaryWordsView({Key? key}) : super(key: key);

  @override
  State<DictionaryWordsView> createState() => _DictionaryWordsViewState();
}

class _DictionaryWordsViewState extends State<DictionaryWordsView> {
  final DictionaryWordsService _dictionaryWordsService = DictionaryWordsService();
  final RootWordsService _rootWordsService = RootWordsService();
  final QuranDatabaseService _quranDatabaseService = QuranDatabaseService();

  final TextEditingController _arabicWordController = TextEditingController();
  final TextEditingController _rootSearchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

  final FocusNode _arabicWordFocus = FocusNode();
  final FocusNode _rootSearchFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<RootWordModel> _rootWords = [];
  List<DictionaryWordModel> _dictionaryWords = [];
  List<RootWordModel> _filteredRootWords = [];
  List<Map<String, dynamic>> _sqliteWordSuggestions = [];

  String? _selectedRootHash;
  bool _showForm = false;
  bool _showSuggestions = false;
  bool _showSqliteSuggestions = false;
  bool _isSaving = false;

  DictionaryWordModel? _editingWord;
  Timer? _searchDebounceTimer;

  /// Active controller for Urdu keyboard input
  TextEditingController? _activeKeyboardController;

  /// Toggle Urdu keyboard visibility (hide/show for phone/web)
  bool _showUrduKeyboard = true;

  // Pagination state (like subject_detail_screen)
  bool _loading = false;
  int _selectedPage = 1;
  int _currentPage = 1;
  int _totalCount = 0;
  Map<int, DocumentSnapshot?> _pageCursors = {};
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadRootWords();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    
    // Listen to focus changes to update active keyboard controller
    _arabicWordFocus.addListener(() {
      if (_arabicWordFocus.hasFocus) {
        setState(() => _activeKeyboardController = _arabicWordController);
      }
    });
    _rootSearchFocus.addListener(() {
      if (_rootSearchFocus.hasFocus) {
        setState(() => _activeKeyboardController = _rootSearchController);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _arabicWordController.dispose();
    _rootSearchController.dispose();
    _pageController.dispose();
    _arabicWordFocus.dispose();
    _rootSearchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadData({int? revertPageOnSkip}) async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      _totalCount = await _dictionaryWordsService.getDictionaryWordsCount();

      // Fetch only target page: build cursor only for immediate previous page (1 extra fetch max)
      final needCursorFor = _selectedPage > 1 ? _selectedPage - 1 : 0;
      if (needCursorFor > 0 && !_pageCursors.containsKey(needCursorFor)) {
        if (needCursorFor == 1) {
          final r = await _dictionaryWordsService.getDictionaryWordsPaginated(limit: _itemsPerPage, startAfterDocument: null);
          final last = r['lastDocument'] as DocumentSnapshot?;
          if (last != null) _pageCursors[1] = last;
        } else if (_pageCursors.containsKey(needCursorFor - 1)) {
          final r = await _dictionaryWordsService.getDictionaryWordsPaginated(
            limit: _itemsPerPage,
            startAfterDocument: _pageCursors[needCursorFor - 1],
          );
          final last = r['lastDocument'] as DocumentSnapshot?;
          if (last != null) _pageCursors[needCursorFor] = last;
        } else {
          toast('Use Previous/Next to reach this page (reduces Firebase reads)');
          if (mounted && revertPageOnSkip != null) setState(() => _selectedPage = revertPageOnSkip);
          setState(() => _loading = false);
          return;
        }
      }

      final result = await _dictionaryWordsService.getDictionaryWordsPaginated(
        limit: _itemsPerPage,
        startAfterDocument:
            _selectedPage > 1 ? _pageCursors[_selectedPage - 1] : null,
      );

      if (mounted) {
        setState(() {
          _dictionaryWords = (result['items'] as List<DictionaryWordModel>);
          final lastDoc = result['lastDocument'] as DocumentSnapshot?;
          if (lastDoc != null) {
            _pageCursors[_selectedPage] = lastDoc;
          }
        });
      }
    } catch (e) {
      if (mounted) toast('Error loading dictionary words: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadRootWords() async {
    try {
      // Minimal initial load for dropdown; user can search for more
      final result = await _rootWordsService.getRootWordsPaginated(
        limit: 50,
        startAfterDocument: null,
      );
      _rootWords = (result['items'] as List<RootWordModel>);
      setState(() {});
    } catch (e) {
      toast("Error loading root words");
    }
  }

  void _openAddForm() {
    setState(() {
      _editingWord = null;
      _arabicWordController.clear();
      _rootSearchController.clear();
      _selectedRootHash = null;
      _filteredRootWords = [];
      _sqliteWordSuggestions = [];
      _showSuggestions = false;
      _showSqliteSuggestions = false;
      _showForm = true;
      _activeKeyboardController = _arabicWordController;
    });
  }

  void _openEditForm(DictionaryWordModel word) {
    final root = _rootWords.firstWhere(
          (e) => e.id == word.rootHash,
      orElse: () => RootWordModel(rootWord: "Unknown"),
    );

    setState(() {
      _editingWord = word;
      _arabicWordController.text = word.arabicWord ?? "";
      _rootSearchController.text =
          (root.triLiteralWord ?? root.rootWord ?? "").trim();
      _selectedRootHash = root.id;
      _showSuggestions = false;
      _showForm = true;
      _activeKeyboardController = _arabicWordController;
    });
  }

  /// Filter root words by triLiteralWord (Trilateral root e.g. "ر ب ب")
  /// Limit to first 5 matches
  void _filterRootWords(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRootWords = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _filteredRootWords = _rootWords
          .where((e) =>
              (e.triLiteralWord ?? "")
                  .toLowerCase()
                  .contains(query.trim().toLowerCase()))
          .take(5)
          .toList();

      _showSuggestions = _filteredRootWords.isNotEmpty;
    });
  }

  Widget _buildCopyPasteButtons(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(top: 6),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: text));
                toast('Copied to clipboard');
              } else {
                toast('Nothing to copy');
              }
            },
            icon: Icon(Icons.copy, size: 18),
            label: Text('Copy'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          8.width,
          OutlinedButton.icon(
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data != null && data.text != null && data.text!.isNotEmpty) {
                controller.text = data.text!;
                setState(() {});
                toast('Pasted');
              } else {
                toast('Clipboard is empty');
              }
            },
            icon: Icon(Icons.paste, size: 18),
            label: Text('Paste'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _selectRootWord(RootWordModel root) {
    setState(() {
      // Show triLiteralWord when available (matches search), else rootWord
      _rootSearchController.text =
          (root.triLiteralWord ?? root.rootWord ?? "").trim();
      _selectedRootHash = root.id;
      _showSuggestions = false;
    });
  }

  /// Search SQLite database for Arabic words (with debounce)
  void _searchSqliteWords(String query) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _sqliteWordSuggestions = [];
        _showSqliteSuggestions = false;
      });
      return;
    }

    // Debounce search by 300ms
    _searchDebounceTimer = Timer(Duration(milliseconds: 300), () async {
      try {
        final results = await _quranDatabaseService.searchArabicWords(query, limit: 20);
        if (mounted) {
          setState(() {
            _sqliteWordSuggestions = results;
            _showSqliteSuggestions = results.isNotEmpty;
          });
        }
      } catch (e) {
        log('Error searching SQLite words: $e');
        if (mounted) {
          setState(() {
            _sqliteWordSuggestions = [];
            _showSqliteSuggestions = false;
          });
        }
      }
    });
  }

  /// Select SQLite word suggestion
  void _selectSqliteWord(Map<String, dynamic> wordData) {
    setState(() {
      _arabicWordController.text = wordData['arabic_word'] ?? '';
      _showSqliteSuggestions = false;
      
      // If root word hash already exists, try to find and select it
      final existingRootHash = wordData['rootword_hash_id'] as String?;
      if (existingRootHash != null && existingRootHash.isNotEmpty) {
        final root = _rootWords.firstWhere(
          (e) => e.id == existingRootHash,
          orElse: () => RootWordModel(),
        );
        if (root.id != null) {
          _rootSearchController.text = root.rootWord ?? '';
          _selectedRootHash = root.id;
        }
      }
    });
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRootHash == null) {
      toast("Please select a root word");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final arabicWordText = _arabicWordController.text.trim();
      
      final newWord = DictionaryWordModel(
        id: _editingWord?.id,
        arabicWord: arabicWordText,
        rootHash: _selectedRootHash,
      );

      if (_editingWord == null) {
        await _dictionaryWordsService.addDictionaryWord(newWord);
        toast("Word added");
      } else {
        await _dictionaryWordsService.updateDictionaryWord(newWord);
        toast("Word updated");
      }

      // Update SQLite database with root word hash
      try {
        await _quranDatabaseService.updateRootWordHashIdByArabicText(
          arabicText: arabicWordText,
          rootWordHashId: _selectedRootHash,
        );
        log('Updated SQLite database with root word hash');
      } catch (e) {
        log('Error updating SQLite database: $e');
        // Don't show error to user, just log it
      }

      setState(() => _showForm = false);
      _loadData();
    } catch (e) {
      toast("Error saving word");
    }

    setState(() => _isSaving = false);
  }

  Future<void> _deleteWord(DictionaryWordModel word) async {
    bool? confirm = await showConfirmDialog(context, "Delete this word?");
    if (confirm ?? false) {
      await _dictionaryWordsService.deleteDictionaryWord(word.id!);
      toast("Deleted");
      _loadData();
    }
  }

  Widget _buildPaginationControls() {
    final totalPages =
        _totalCount == 0 ? 1 : (_totalCount / _itemsPerPage).ceil();

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20),
            onPressed: _selectedPage > 1
                ? () async {
                    setState(() => _selectedPage--);
                    await _loadData();
                  }
                : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_currentPage > 1) ...[
                    _buildPageButton(1),
                    if (_currentPage > 2) Text('...'),
                  ],
                  for (int i = _currentPage;
                      i <= _currentPage + 7 && i <= totalPages;
                      i++)
                    _buildPageButton(i),
                  if (_currentPage + 7 < totalPages) ...[
                    if (_currentPage + 8 < totalPages) Text('...'),
                    _buildPageButton(totalPages),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: _selectedPage < totalPages
                ? () async {
                    setState(() {
                      _selectedPage++;
                      if (_selectedPage > _currentPage + 7) {
                        _currentPage = _selectedPage;
                      }
                    });
                    await _loadData();
                  }
                : null,
          ),
          Container(
            width: 100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Page',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final input = _pageController.text.trim();
                    if (input.isNotEmpty) {
                      final pageNumber = int.tryParse(input);
                      final totalPages = _totalCount == 0
                          ? 1
                          : (_totalCount / _itemsPerPage).ceil();
                      if (pageNumber != null &&
                          pageNumber >= 1 &&
                          pageNumber <= totalPages) {
                        final prevPage = _selectedPage;
                        setState(() {
                          _selectedPage = pageNumber;
                          _currentPage = ((pageNumber - 1) ~/ 8) * 8 + 1;
                        });
                        await _loadData(revertPageOnSkip: prevPage);
                        _pageController.clear();
                      }
                    }
                  },
                  child: Text('Go', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int pageNumber) {
    final totalPages =
        _totalCount == 0 ? 1 : (_totalCount / _itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: GestureDetector(
        onTap: () async {
          setState(() => _selectedPage = pageNumber);
          await _loadData();
        },
        child: CircleAvatar(
          radius: 16,
          backgroundColor: pageNumber == _selectedPage
              ? Colors.green
              : Colors.grey[300],
          child: Text(
            '$pageNumber',
            style: TextStyle(
              color: pageNumber == _selectedPage ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dictionary Words", style: boldTextStyle(color: white)),
        backgroundColor: colorPrimary,
        actions: [
          if (!_showForm) ...[
            IconButton(
              icon: Icon(Icons.info_outline, color: white),
              onPressed: () async {
                // Verify table structure
                final structure = await _quranDatabaseService.verifyTableStructure();
                final dbPath = await _quranDatabaseService.getDatabasePath();
                final sampleData = await _quranDatabaseService.getSampleData(limit: 3);
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Database Info'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Database Path:', style: boldTextStyle()),
                          Text(dbPath ?? 'Unknown', style: secondaryTextStyle()),
                          16.height,
                          Text('Table Structure:', style: boldTextStyle()),
                          8.height,
                          if (structure['table1'] != null) ...[
                            Text('${structure['table1']['name']}:', style: boldTextStyle(size: 14)),
                            Text('  Columns: ${structure['table1']['columns']}', style: secondaryTextStyle(size: 12)),
                            Text('  Has rootword_hash_id: ${structure['table1']['has_rootword_hash_id']}', 
                              style: secondaryTextStyle(size: 12, color: structure['table1']['has_rootword_hash_id'] ? Colors.green : Colors.red)),
                          ],
                          8.height,
                          if (structure['table2'] != null) ...[
                            Text('${structure['table2']['name']}:', style: boldTextStyle(size: 14)),
                            Text('  Columns: ${structure['table2']['columns']}', style: secondaryTextStyle(size: 12)),
                            Text('  Has rootword_hash_id: ${structure['table2']['has_rootword_hash_id']}', 
                              style: secondaryTextStyle(size: 12, color: structure['table2']['has_rootword_hash_id'] ? Colors.green : Colors.red)),
                          ],
                          16.height,
                          Text('Sample Data with rootword_hash_id:', style: boldTextStyle()),
                          if (sampleData.isEmpty)
                            Text('No data found with rootword_hash_id', style: secondaryTextStyle(size: 12, color: Colors.orange))
                          else
                            ...sampleData.take(3).map((row) => Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '${row['table']}: ${row['Arabic_Text']} -> ${row['rootword_hash_id']}',
                                style: secondaryTextStyle(size: 11),
                              ),
                            )),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final success = await _quranDatabaseService.forceAddRootWordHashIdColumn();
                          Navigator.pop(context);
                          toast(success ? 'Column added successfully' : 'Failed to add column. Check logs.');
                          // Refresh info
                          final structure = await _quranDatabaseService.verifyTableStructure();
                          log('After force add: $structure');
                        },
                        child: Text('Force Add Column'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Database Info',
            ),
            IconButton(
              icon: Icon(Icons.add, color: white),
              onPressed: _openAddForm,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_showForm)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        color: white,
                        child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    10.height,

                    // Arabic Word field - Urdu/Arabic keyboard, RTL, copy-paste
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _arabicWordController,
                          focus: _arabicWordFocus,
                          textFieldType: TextFieldType.OTHER,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.right,
                          textStyle: TextStyle(
                            fontFamily: 'ArabicFonts',
                            fontSize: 18,
                          ),
                          decoration: inputDecoration(labelText: "Arabic Word *"),
                          validator: (v) => v!.trim().isEmpty ? "Required" : null,
                          onChanged: (value) {
                            _searchSqliteWords(value);
                          },
                        ),
                        _buildCopyPasteButtons(_arabicWordController),
                      ],
                    ),

                    if (_showSqliteSuggestions)
                      Container(
                        height: 200,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: radius(8),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: ListView.builder(
                          itemCount: _sqliteWordSuggestions.length,
                          itemBuilder: (_, i) {
                            final wordData = _sqliteWordSuggestions[i];
                            final arabicWord = wordData['arabic_word'] ?? '';
                            final urduWord = wordData['urdu_word'] as String?;
                            final rootHashId = wordData['rootword_hash_id'] as String?;
                            final sourceTable = wordData['source_table'] ?? '';
                            
                            return ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (arabicWord.isNotEmpty)
                                    Text(
                                      arabicWord,
                                      style: TextStyle(
                                        fontFamily: 'ArabicFonts',
                                        fontSize: 18,
                                      ),
                                    ),
                                  if (urduWord != null && urduWord.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      urduWord,
                                      style: TextStyle(
                                        fontFamily: 'UrduFonts',
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Text('Source: $sourceTable', style: TextStyle(fontSize: 11)),
                                  if (rootHashId != null && rootHashId.isNotEmpty) ...[
                                    SizedBox(width: 8),
                                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text('Has root', style: TextStyle(color: Colors.green, fontSize: 11)),
                                  ],
                                ],
                              ),
                              trailing: rootHashId != null && rootHashId.isNotEmpty
                                  ? Icon(Icons.link, color: Colors.green, size: 20)
                                  : null,
                              onTap: () => _selectSqliteWord(wordData),
                            );
                          },
                        ),
                      ),

                    20.height,

                    // Search Root Word field - Urdu/Arabic keyboard, RTL, copy-paste
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _rootSearchController,
                          focus: _rootSearchFocus,
                          textFieldType: TextFieldType.OTHER,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.right,
                          textStyle: TextStyle(
                            fontFamily: 'ArabicFonts',
                            fontSize: 18,
                          ),
                          decoration: inputDecoration(
                              labelText: "Search Root Word (by Tri-literal) *"),
                          onChanged: _filterRootWords,
                          onTap: () {
                            setState(() {
                              if (_rootSearchController.text.isEmpty) {
                                _filteredRootWords = _rootWords.take(5).toList();
                              } else {
                                _filterRootWords(_rootSearchController.text);
                              }
                              _showSuggestions = true;
                            });
                          },
                          validator: (v) {
                            if (_selectedRootHash == null) return "Select a root word";
                            return null;
                          },
                        ),
                        _buildCopyPasteButtons(_rootSearchController),
                      ],
                    ),

                    if (_showSuggestions)
                      Container(
                        height: 180,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: radius(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.builder(
                          itemCount: _filteredRootWords.length,
                          itemBuilder: (_, i) {
                            final word = _filteredRootWords[i];
                            return ListTile(
                              title: Text(
                                word.triLiteralWord ?? word.rootWord ?? "",
                                style: TextStyle(
                                  fontFamily: 'ArabicFonts',
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${word.rootWord ?? ""}${(word.description ?? "").isNotEmpty ? " - ${word.description}" : ""}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectRootWord(word),
                            );
                          },
                        ),
                      ),

                    20.height,

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: _editingWord == null ? "Add Word" : "Update Word",
                            onTap: _isSaving ? null : _saveWord,
                            color: selectedDrawerViewColor,
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: AppButton(
                            text: "Cancel",
                            color: white,
                            textStyle: boldTextStyle(color: colorPrimary),
                            onTap: () => setState(() => _showForm = false),
                          ),
                        ),
                      ],
                    ),

                    if (_isSaving) 20.height,
                    if (_isSaving) CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
                  ),
                ),
                // Urdu keyboard with hide/show toggle
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Urdu Keyboard',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    TextButton.icon(
                      icon: Icon(
                        _showUrduKeyboard ? Icons.keyboard_hide : Icons.keyboard,
                        size: 20,
                        color: colorPrimary,
                      ),
                      label: Text(
                        _showUrduKeyboard ? 'Hide' : 'Show',
                        style: TextStyle(color: colorPrimary, fontSize: 12),
                      ),
                      onPressed: () => setState(() => _showUrduKeyboard = !_showUrduKeyboard),
                    ),
                  ],
                ),
                if (_showUrduKeyboard)
                  UrduKeyboard(
                    controller: _activeKeyboardController ?? _arabicWordController,
                    keyHeight: 40,
                    keyFontSize: 16,
                  ),
              ],
            ),
          ),

          if (!_showForm)
            Expanded(
              child: _loading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Page $_selectedPage of ${_totalCount == 0 ? 1 : (_totalCount / _itemsPerPage).ceil()} - Showing ${_dictionaryWords.length} (Total: $_totalCount)',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(
                        child: _dictionaryWords.isEmpty
                            ? Center(child: Text("No dictionary words found"))
                            : Builder(
                                builder: (context) {
                                  final rootMap = {
                                    for (var r in _rootWords)
                                      if (r.id != null) r.id!: r
                                  };
                                  return ListView.builder(
                                    itemCount: _dictionaryWords.length,
                                    itemBuilder: (_, i) {
                                      final word = _dictionaryWords[i];
                                      final root = rootMap[word.rootHash] ??
                                          RootWordModel(rootWord: "Unknown");

                                      return Card(
                                        margin: EdgeInsets.all(12),
                                        child: ListTile(
                                          title: Text(word.arabicWord ?? ""),
                                          subtitle: Text(
                                              "Root: ${root.rootWord}"),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit,
                                                    color: Colors.blue),
                                                onPressed: () =>
                                                    _openEditForm(word),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _deleteWord(word),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                      _buildPaginationControls(),
                    ],
                  ),
            ),
        ],
      ),
    );
  }
}
