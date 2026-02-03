import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/RootWordModel.dart';
import 'package:quizeapp/services/RootWordsService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/widgets/urdu_keyboard.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../../main.dart';

class RootWordsView extends StatefulWidget {
  const RootWordsView({Key? key}) : super(key: key);

  @override
  State<RootWordsView> createState() => _RootWordsViewState();
}

class _RootWordsViewState extends State<RootWordsView> {
  final RootWordsService _rootWordsService = RootWordsService();
  final TextEditingController _rootWordController = TextEditingController();
  final TextEditingController _triliteralRootWordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urduShortMeaningController = TextEditingController();
  final TextEditingController _englishShortMeaningController = TextEditingController();
  final TextEditingController _urduLongMeaningController = TextEditingController();
  final TextEditingController _englishLongMeaningController = TextEditingController();
  
  final FocusNode _rootWordFocus = FocusNode();
  final FocusNode _triliteralFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _urduShortFocus = FocusNode();
  final FocusNode _englishShortFocus = FocusNode();
  final FocusNode _urduLongFocus = FocusNode();
  final FocusNode _englishLongFocus = FocusNode();
  final FocusNode _searchFocus = FocusNode();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  RootWordModel? _editingWord;
  bool _isLoading = false;
  bool _showForm = false;
  // Pagination state (like subject_detail_screen)
  List<RootWordModel> _rootWords = [];
  bool _loading = false;
  int _selectedPage = 1;
  int _currentPage = 1;
  int _totalCount = 0;
  Map<int, DocumentSnapshot?> _pageCursors = {};
  final TextEditingController _pageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  static const int _itemsPerPage = 10;

  /// Search state
  List<RootWordModel> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounceTimer;

  /// Active controller for Urdu keyboard input
  TextEditingController? _activeKeyboardController;

  /// Toggle Urdu keyboard visibility (hide/show for phone/web)
  bool _showUrduKeyboard = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    
    // Listen to focus changes to update active keyboard controller
    _rootWordFocus.addListener(() {
      if (_rootWordFocus.hasFocus) {
        setState(() => _activeKeyboardController = _rootWordController);
      }
    });
    _triliteralFocus.addListener(() {
      if (_triliteralFocus.hasFocus) {
        setState(() => _activeKeyboardController = _triliteralRootWordController);
      }
    });
    _descriptionFocus.addListener(() {
      if (_descriptionFocus.hasFocus) {
        setState(() => _activeKeyboardController = _descriptionController);
      }
    });
    _urduShortFocus.addListener(() {
      if (_urduShortFocus.hasFocus) {
        setState(() => _activeKeyboardController = _urduShortMeaningController);
      }
    });
    _englishShortFocus.addListener(() {
      if (_englishShortFocus.hasFocus) {
        setState(() => _activeKeyboardController = _englishShortMeaningController);
      }
    });
    _urduLongFocus.addListener(() {
      if (_urduLongFocus.hasFocus) {
        setState(() => _activeKeyboardController = _urduLongMeaningController);
      }
    });
    _englishLongFocus.addListener(() {
      if (_englishLongFocus.hasFocus) {
        setState(() => _activeKeyboardController = _englishLongMeaningController);
      }
    });
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        setState(() => _activeKeyboardController = _searchController);
      }
    });
  }

  @override
  void dispose() {
    _rootWordController.dispose();
    _descriptionController.dispose();
    _triliteralRootWordController.dispose();
    _urduShortMeaningController.dispose();
    _englishShortMeaningController.dispose();
    _urduLongMeaningController.dispose();
    _englishLongMeaningController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    
    _rootWordFocus.dispose();
    _triliteralFocus.dispose();
    _descriptionFocus.dispose();
    _urduShortFocus.dispose();
    _englishShortFocus.dispose();
    _urduLongFocus.dispose();
    _englishLongFocus.dispose();
    _searchFocus.dispose();
    
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> _loadData({int? revertPageOnSkip}) async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      _totalCount = await _rootWordsService.getRootWordsCount();

      // Fetch only target page: build cursor only for immediate previous page (1 extra fetch max)
      final needCursorFor = _selectedPage > 1 ? _selectedPage - 1 : 0;
      if (needCursorFor > 0 && !_pageCursors.containsKey(needCursorFor)) {
        if (needCursorFor == 1) {
          final r = await _rootWordsService.getRootWordsPaginated(limit: _itemsPerPage, startAfterDocument: null);
          final last = r['lastDocument'] as DocumentSnapshot?;
          if (last != null) _pageCursors[1] = last;
        } else if (_pageCursors.containsKey(needCursorFor - 1)) {
          final r = await _rootWordsService.getRootWordsPaginated(
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

      final result = await _rootWordsService.getRootWordsPaginated(
        limit: _itemsPerPage,
        startAfterDocument:
            _selectedPage > 1 ? _pageCursors[_selectedPage - 1] : null,
      );

      if (mounted) {
        setState(() {
          _rootWords = (result['items'] as List<RootWordModel>);
          final lastDoc = result['lastDocument'] as DocumentSnapshot?;
          if (lastDoc != null) {
            _pageCursors[_selectedPage] = lastDoc;
          }
        });
      }
    } catch (e) {
      if (mounted) toast('Error loading root words: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Search root words with debounce
  void _searchRootWords(String query) {
    _searchDebounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    _searchDebounceTimer = Timer(Duration(milliseconds: 300), () async {
      setState(() => _isSearching = true);
      try {
        final results = await _rootWordsService.searchRootWords(query, limit: 30);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        log('Error searching root words: $e');
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  void _clearForm({bool hideForm = true}) {
    _activeKeyboardController = null;
    if (!hideForm) {
      // Opening add form - clear search
      _searchController.clear();
      _searchResults = [];
    }
    _rootWordController.clear();
    _descriptionController.clear();
    _triliteralRootWordController.clear();
    _urduShortMeaningController.clear();
    _englishShortMeaningController.clear();
    _urduLongMeaningController.clear();
    _englishLongMeaningController.clear();

    _editingWord = null;
    if (hideForm) {
      _showForm = false;
    }
  }

  void _editWord(RootWordModel word) {
    setState(() {
      _activeKeyboardController = _rootWordController;
      _editingWord = word;
      _rootWordController.text = word.rootWord ?? '';
      _descriptionController.text = word.description ?? '';
      _triliteralRootWordController.text = word.triLiteralWord ?? '';
      _urduShortMeaningController.text = word.urduShortMeaning ?? '';
      _englishShortMeaningController.text = word.englishShortMeaning ?? '';
      _urduLongMeaningController.text = word.urduLongMeaning ?? '';
      _englishLongMeaningController.text = word.englishLongMeaning ?? '';
      _showForm = true;
    });
  }

  Future<void> _saveRootWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final rootWord = RootWordModel(
        id: _editingWord?.id,
        rootWord: _rootWordController.text.trim(),
        description: _descriptionController.text.trim(),
        triLiteralWord: _triliteralRootWordController.text.trim(),
        urduShortMeaning: _urduShortMeaningController.text.trim(),
        englishShortMeaning: _englishShortMeaningController.text.trim(),
        urduLongMeaning: _urduLongMeaningController.text.trim(),
        englishLongMeaning: _englishLongMeaningController.text.trim(),

      );

      if (_editingWord == null) {
        await _rootWordsService.addRootWord(rootWord);
        toast('Root word added successfully');
      } else {
        await _rootWordsService.updateRootWord(rootWord);
        toast('Root word updated successfully');
      }

      _clearForm(hideForm: true);
      _loadData();
    } catch (e) {
      toast('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteWord(RootWordModel word) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Root Word'),
          content: Text('Are you sure you want to delete "${word.rootWord}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _rootWordsService.deleteRootWord(word.id!);
        toast('Root word deleted successfully');
        _loadData();
      } catch (e) {
        toast('Error deleting root word: ${e.toString()}');
      }
    }
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
          SizedBox(width: 8),
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

  Widget _buildPaginationControls() {
    final totalPages = _totalCount == 0 ? 1 : (_totalCount / _itemsPerPage).ceil();

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
                      final totalPages =
                          _totalCount == 0 ? 1 : (_totalCount / _itemsPerPage).ceil();
                      if (pageNumber != null &&
                          pageNumber >= 1 &&
                          pageNumber <= totalPages) {
                        final prevPage = _selectedPage;
                        setState(() {
                          _selectedPage = pageNumber;
                          _currentPage =
                              ((pageNumber - 1) ~/ 8) * 8 + 1;
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
    final totalPages = _totalCount == 0 ? 1 : (_totalCount / _itemsPerPage).ceil();

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Root Words Management', style: boldTextStyle(color: Colors.white)),
        backgroundColor: colorPrimary,
        elevation: 0,
        actions: [
          if (!_showForm)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                setState(() {
                  _clearForm(hideForm: false);
                  _showForm = true;
                  _activeKeyboardController = _rootWordController;
                });
              },
              tooltip: 'Add New Root Word',
            ),
        ],
      ),
      body: Column(
        children: [
          // Form Section with Urdu keyboard
          if (_showForm)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _editingWord == null ? 'Add Root Word' : 'Edit Root Word',
                                style: boldTextStyle(size: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => setState(() => _clearForm(hideForm: true)),
                              ),
                            ],
                          ),
                          16.height,
                          // Root Word - Urdu/Arabic keyboard, RTL, copy-paste
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                controller: _rootWordController,
                                focus: _rootWordFocus,
                                textFieldType: TextFieldType.OTHER,
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.right,
                                textStyle: TextStyle(
                                  fontFamily: 'ArabicFonts',
                                  fontSize: 18,
                                ),
                                decoration: inputDecoration(labelText: 'Root Word *'),
                                isValidationRequired: false,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Root word is required';
                                  }
                                  return null;
                                },
                              ),
                              _buildCopyPasteButtons(_rootWordController),
                            ],
                          ),
                          16.height,
                          AppTextField(
                            controller: _descriptionController,
                            focus: _descriptionFocus,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 3,
                            decoration: inputDecoration(labelText: 'Description'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          // Triliteral Root - Urdu/Arabic keyboard, RTL, copy-paste
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                controller: _triliteralRootWordController,
                                focus: _triliteralFocus,
                                textFieldType: TextFieldType.MULTILINE,
                                keyboardType: TextInputType.multiline,
                                textAlign: TextAlign.right,
                                textStyle: TextStyle(
                                  fontFamily: 'ArabicFonts',
                                  fontSize: 16,
                                ),
                                maxLines: 3,
                                decoration: inputDecoration(labelText: 'Triliteral Root'),
                                isValidationRequired: false,
                                validator: (_) => null,
                              ),
                              _buildCopyPasteButtons(_triliteralRootWordController),
                            ],
                          ),
                          16.height,
                          // Urdu Short Meaning - Urdu keyboard, RTL, copy-paste
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                controller: _urduShortMeaningController,
                                focus: _urduShortFocus,
                                textFieldType: TextFieldType.MULTILINE,
                                keyboardType: TextInputType.multiline,
                                textAlign: TextAlign.right,
                                textStyle: TextStyle(
                                  fontFamily: 'UrduFonts',
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                decoration: inputDecoration(labelText: 'Urdu Short Meaning'),
                                isValidationRequired: false,
                                validator: (_) => null,
                              ),
                              _buildCopyPasteButtons(_urduShortMeaningController),
                            ],
                          ),
                          16.height,
                          AppTextField(
                            controller: _englishShortMeaningController,
                            focus: _englishShortFocus,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 2,
                            decoration: inputDecoration(labelText: 'English Short Meaning'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          // Urdu Long Meaning - Urdu keyboard, RTL, copy-paste
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                controller: _urduLongMeaningController,
                                focus: _urduLongFocus,
                                textFieldType: TextFieldType.MULTILINE,
                                keyboardType: TextInputType.multiline,
                                textAlign: TextAlign.right,
                                textStyle: TextStyle(
                                  fontFamily: 'UrduFonts',
                                  fontSize: 16,
                                ),
                                maxLines: 3,
                                decoration: inputDecoration(labelText: 'Urdu Long Meaning'),
                                isValidationRequired: false,
                                validator: (_) => null,
                              ),
                              _buildCopyPasteButtons(_urduLongMeaningController),
                            ],
                          ),
                          16.height,
                          AppTextField(
                            controller: _englishLongMeaningController,
                            focus: _englishLongFocus,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 3,
                            decoration: inputDecoration(labelText: 'English Long Meaning'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: _editingWord == null ? 'Add Root Word' : 'Update Root Word',
                                  textStyle: boldTextStyle(color: white),
                                  color: colorPrimary,
                                  onTap: _isLoading ? null : _saveRootWord,
                                ),
                              ),
                              12.width,
                              Expanded(
                                child: AppButton(
                                  text: 'Cancel',
                                  textStyle: boldTextStyle(color: colorPrimary),
                                  color: Colors.white,
                                  onTap: () => setState(() => _clearForm(hideForm: true)),
                                ),
                              ),
                            ],
                          ),
                          if (_isLoading) ...[
                            16.height,
                            Center(child: CircularProgressIndicator()),
                          ],
                        ],
                      ),
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
                    controller: _activeKeyboardController ?? _rootWordController,
                    keyHeight: 40,
                    keyFontSize: 16,
                  ),
              ],
            ),
          ),

          // List Section with pagination and search
          if (!_showForm)
            Expanded(
              child: _loading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: colorPrimary),
                          16.height,
                          Text('Loading root words...'),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Search field (with Urdu keyboard support)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                controller: _searchController,
                                focus: _searchFocus,
                                textFieldType: TextFieldType.OTHER,
                                textAlign: TextAlign.right,
                                textStyle: TextStyle(
                                  fontFamily: 'ArabicFonts',
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'روٹ لفظ، ثلاثی یا وضاحت سے تلاش کریں...',
                                  prefixIcon: Icon(Icons.search),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, size: 20),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchResults = [];
                                              _isSearching = false;
                                            });
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                  _searchRootWords(value);
                                },
                              ),
                              _buildCopyPasteButtons(_searchController),
                            ],
                          ),
                        ),
                        // Pagination info (hide when searching)
                        if (_searchController.text.trim().isEmpty)
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Page $_selectedPage of ${_totalCount == 0 ? 1 : (_totalCount / _itemsPerPage).ceil()} - Showing ${_rootWords.length} (Total: $_totalCount)',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        Expanded(
                          child: _isSearching
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: colorPrimary),
                                      12.height,
                                      Text('Searching...', style: secondaryTextStyle()),
                                    ],
                                  ),
                                )
                              : _searchController.text.trim().isNotEmpty
                                  ? (_searchResults.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No root words found',
                                            style: secondaryTextStyle(color: Colors.grey[600]),
                                          ),
                                        )
                                      : _buildListView(_searchResults, onItemTap: _editWord))
                                  : _rootWords.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.library_books_outlined,
                                                  size: 64, color: Colors.grey[400]),
                                              16.height,
                                              Text('No Root Words',
                                                  style: boldTextStyle(
                                                      size: 18,
                                                      color: Colors.grey[600])),
                                              8.height,
                                              Text(
                                                  'Add your first root word to get started',
                                                  style: secondaryTextStyle(
                                                      color: Colors.grey[500])),
                                              24.height,
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    _clearForm(hideForm: false);
                                                    _showForm = true;
                                                  });
                                                },
                                                icon: Icon(Icons.add),
                                                label: Text('Add First Root Word'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorPrimary,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 24, vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(12)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : _buildListView(_rootWords)),
                        // Urdu keyboard toggle + keyboard for list/search view
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Row(
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
                                  size: 18,
                                  color: colorPrimary,
                                ),
                                label: Text(
                                  _showUrduKeyboard ? 'Hide' : 'Show',
                                  style: TextStyle(color: colorPrimary, fontSize: 11),
                                ),
                                onPressed: () => setState(() => _showUrduKeyboard = !_showUrduKeyboard),
                              ),
                            ],
                          ),
                        ),
                        if (_showUrduKeyboard)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: UrduKeyboard(
                              controller: _activeKeyboardController ?? _searchController,
                              keyHeight: 32,
                              keyFontSize: 14,
                            ),
                          ),
                        if (_searchController.text.trim().isNotEmpty)
                          4.height,
                        if (_searchController.text.trim().isEmpty)
                          _buildPaginationControls(),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(List<RootWordModel> rootWords, {void Function(RootWordModel)? onItemTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Root Words: ${rootWords.length}',
                  style: boldTextStyle(size: 14, color: colorPrimary),
                ),
              ],
            ),
          ),
          // List items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: rootWords.length,
              itemBuilder: (context, index) {
                final word = rootWords[index];
                final tile = ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: boldTextStyle(size: 14, color: colorPrimary),
                        ),
                      ),
                    ),
                    title: Text(
                      word.rootWord ?? '',
                      style: boldTextStyle(size: 16, color: colorPrimary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colorPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: colorPrimary, size: 20),
                            onPressed: () => _editWord(word),
                            tooltip: 'Edit',
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _deleteWord(word),
                            tooltip: 'Delete',
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      if (word.triLiteralWord.validate().isNotEmpty) ...[
                        _buildInfoRow('Trilateral Root', word.triLiteralWord ?? ''),
                      ],
                      if (word.urduShortMeaning.validate().isNotEmpty) ...[
                        _buildInfoRow('Urdu Short Meaning', word.urduShortMeaning ?? ''),
                      ],
                      if (word.englishShortMeaning.validate().isNotEmpty) ...[
                        _buildInfoRow('English Short Meaning', word.englishShortMeaning ?? ''),
                      ],
                      if (word.urduLongMeaning.validate().isNotEmpty) ...[
                        _buildInfoRow('Urdu Long Meaning', word.urduLongMeaning ?? ''),
                      ],
                      if (word.englishLongMeaning.validate().isNotEmpty) ...[
                        _buildInfoRow('English Long Meaning', word.englishLongMeaning ?? ''),
                      ],
                      if (word.description.validate().isNotEmpty) ...[
                        _buildInfoRow('Description', word.description ?? ''),
                      ],
                    ],
                  );
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: onItemTap != null
                      ? InkWell(
                          onTap: () => onItemTap!(word),
                          borderRadius: BorderRadius.circular(12),
                          child: tile,
                        )
                      : tile,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: boldTextStyle(size: 12, color: Colors.grey[600]!),
          ),
          4.height,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              value,
              style: secondaryTextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}

