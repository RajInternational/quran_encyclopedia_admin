import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordModel.dart';
import 'package:quizeapp/models/RootWordModel.dart';
import 'package:quizeapp/services/DictionaryWordsService.dart';
import 'package:quizeapp/services/RootWordsService.dart';
import 'package:quizeapp/services/QuranDatabaseService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<RootWordModel> _rootWords = [];
  List<RootWordModel> _filteredRootWords = [];
  List<Map<String, dynamic>> _sqliteWordSuggestions = [];

  String? _selectedRootHash;
  bool _showForm = false;
  bool _showSuggestions = false;
  bool _showSqliteSuggestions = false;
  bool _isSaving = false;

  DictionaryWordModel? _editingWord;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRootWords();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _arabicWordController.dispose();
    _rootSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadRootWords() async {
    try {
      _rootWords = await _rootWordsService.getRootWordsFuture();
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
      _rootSearchController.text = root.rootWord ?? "";
      _selectedRootHash = root.id;
      _showSuggestions = false;
      _showForm = true;
    });
  }

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
          .where((e) => (e.rootWord ?? "").toLowerCase().contains(query.toLowerCase()))
          .toList();

      _showSuggestions = _filteredRootWords.isNotEmpty;
    });
  }

  void _selectRootWord(RootWordModel root) {
    setState(() {
      _rootSearchController.text = root.rootWord ?? "";
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
    }
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
            Container(
              padding: EdgeInsets.all(16),
              color: white,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    10.height,

                    AppTextField(
                      controller: _arabicWordController,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(labelText: "Arabic Word *"),
                      validator: (v) => v!.trim().isEmpty ? "Required" : null,
                      onChanged: (value) {
                        _searchSqliteWords(value);
                      },
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

                    AppTextField(
                      controller: _rootSearchController,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(labelText: "Search Root Word *"),
                      onChanged: _filterRootWords,
                      onTap: () {
                        setState(() {
                          _filteredRootWords = _rootWords;
                          _showSuggestions = true;
                        });
                      },
                      validator: (v) {
                        if (_selectedRootHash == null) return "Select a root word";
                        return null;
                      },
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
                              title: Text(word.rootWord ?? ""),
                              subtitle: Text(
                                word.description ?? "",
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

          Expanded(
            child: StreamBuilder<List<DictionaryWordModel>>(
              stream: _dictionaryWordsService.streamDictionaryWords(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final list = snap.data!;

                if (list.isEmpty) {
                  return Center(child: Text("No dictionary words found"));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final word = list[i];
                    final root = _rootWords.firstWhere(
                          (e) => e.id == word.rootHash,
                      orElse: () => RootWordModel(rootWord: "Unknown"),
                    );

                    return Card(
                      margin: EdgeInsets.all(12),
                      child: ListTile(
                        title: Text(word.arabicWord ?? ""),
                        subtitle: Text("Root: ${root.rootWord}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openEditForm(word),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteWord(word),
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
        ],
      ),
    );
  }
}
