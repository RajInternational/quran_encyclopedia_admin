import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/widgets/urdu_keyboard.dart';

import 'root_word_model.dart';
import 'root_words_firestore_service.dart';

/// View-only Root Words screen: list + search + pagination. No Add/Edit/Delete.
/// Uses local Firebase fetch logic (root_words_firestore_service) for full independence.
class RootWordsViewOnlyScreen extends StatefulWidget {
  const RootWordsViewOnlyScreen({Key? key}) : super(key: key);

  @override
  State<RootWordsViewOnlyScreen> createState() => _RootWordsViewOnlyScreenState();
}

class _RootWordsViewOnlyScreenState extends State<RootWordsViewOnlyScreen> {
  final RootWordsFirestoreService _rootWordsService = RootWordsFirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<RootWordModel> _rootWords = [];
  bool _loading = false;
  int _selectedPage = 1;
  int _currentPage = 1;
  int _totalCount = 0;
  Map<int, DocumentSnapshot<Map<String, dynamic>>?> _pageCursors = {};
  final TextEditingController _pageController = TextEditingController();
  static const int _itemsPerPage = 10;

  List<RootWordModel> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounceTimer;
  TextEditingController? _activeKeyboardController;
  bool _showUrduKeyboard = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        setState(() => _activeKeyboardController = _searchController);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _searchDebounceTimer?.cancel();
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
      final needCursorFor = _selectedPage > 1 ? _selectedPage - 1 : 0;
      if (needCursorFor > 0 && !_pageCursors.containsKey(needCursorFor)) {
        if (needCursorFor == 1) {
          final r = await _rootWordsService.getRootWordsPaginated(limit: _itemsPerPage, startAfterDocument: null);
          final last = r['lastDocument'] as DocumentSnapshot<Map<String, dynamic>>?;
          if (last != null) _pageCursors[1] = last;
        } else if (_pageCursors.containsKey(needCursorFor - 1)) {
          final r = await _rootWordsService.getRootWordsPaginated(
            limit: _itemsPerPage,
            startAfterDocument: _pageCursors[needCursorFor - 1],
          );
          final last = r['lastDocument'] as DocumentSnapshot<Map<String, dynamic>>?;
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
        startAfterDocument: _selectedPage > 1 ? _pageCursors[_selectedPage - 1] : null,
      );
      if (mounted) {
        setState(() {
          _rootWords = (result['items'] as List<RootWordModel>);
          final lastDoc = result['lastDocument'] as DocumentSnapshot<Map<String, dynamic>>?;
          if (lastDoc != null) _pageCursors[_selectedPage] = lastDoc;
        });
      }
    } catch (e) {
      if (mounted) toast('Error loading root words: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _searchRootWords(String query) {
    _searchDebounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    _searchDebounceTimer = Timer(Duration(milliseconds: 150), () async {
      setState(() => _isSearching = true);
      try {
        final results = await _rootWordsService.searchRootWords(query);
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

  Widget _buildCopyPasteButtons(TextEditingController controller, {VoidCallback? onPaste}) {
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
            style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
          SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data != null && data.text != null && data.text!.isNotEmpty) {
                controller.text = data.text!;
                setState(() {});
                onPaste?.call();
                toast('Pasted');
              } else {
                toast('Clipboard is empty');
              }
            },
            icon: Icon(Icons.paste, size: 18),
            label: Text('Paste'),
            style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
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
                  for (int i = _currentPage; i <= _currentPage + 7 && i <= totalPages; i++)
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
                      if (_selectedPage > _currentPage + 7) _currentPage = _selectedPage;
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final input = _pageController.text.trim();
                    if (input.isNotEmpty) {
                      final pageNumber = int.tryParse(input);
                      final totalPages = _totalCount == 0 ? 1 : (_totalCount / _itemsPerPage).ceil();
                      if (pageNumber != null && pageNumber >= 1 && pageNumber <= totalPages) {
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
          backgroundColor: pageNumber == _selectedPage ? Colors.green : Colors.grey[300],
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
        title: Text('Root Words (View Only)', style: boldTextStyle(color: Colors.white)),
        backgroundColor: colorPrimary,
        elevation: 0,
      ),
      body: _loading
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
                        textStyle: TextStyle(fontFamily: 'ArabicFonts', fontSize: 16),
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
                      _buildCopyPasteButtons(
                        _searchController,
                        onPaste: () => _searchRootWords(_searchController.text),
                      ),
                    ],
                  ),
                ),
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
                              : _buildListView(_searchResults))
                          : _rootWords.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
                                      16.height,
                                      Text('No Root Words', style: boldTextStyle(size: 18, color: Colors.grey[600])),
                                      8.height,
                                      Text('No root words to display.', style: secondaryTextStyle(color: Colors.grey[500])),
                                    ],
                                  ),
                                )
                              : _buildListView(_rootWords),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Urdu Keyboard', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ),
                      TextButton.icon(
                        icon: Icon(_showUrduKeyboard ? Icons.keyboard_hide : Icons.keyboard, size: 18, color: colorPrimary),
                        label: Text(_showUrduKeyboard ? 'Hide' : 'Show', style: TextStyle(color: colorPrimary, fontSize: 11)),
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
                if (_searchController.text.trim().isNotEmpty) 4.height,
                if (_searchController.text.trim().isEmpty) _buildPaginationControls(),
              ],
            ),
    );
  }

  Widget _buildListView(List<RootWordModel> rootWords) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Root Words: ${rootWords.length}', style: boldTextStyle(size: 14, color: colorPrimary)),
              ],
            ),
          ),
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
                      child: Text((index + 1).toString(), style: boldTextStyle(size: 14, color: colorPrimary)),
                    ),
                  ),
                  title: Text(word.rootWord ?? '', style: boldTextStyle(size: 16, color: colorPrimary)),
                  children: [
                    if (word.triLiteralWord.validate().isNotEmpty) _buildInfoRow('Trilateral Root', word.triLiteralWord ?? ''),
                    if (word.urduShortMeaning.validate().isNotEmpty) _buildInfoRow('Urdu Short Meaning', word.urduShortMeaning ?? ''),
                    if (word.englishShortMeaning.validate().isNotEmpty) _buildInfoRow('English Short Meaning', word.englishShortMeaning ?? ''),
                    if (word.urduLongMeaning.validate().isNotEmpty) _buildInfoRow('Urdu Long Meaning', word.urduLongMeaning ?? ''),
                    if (word.englishLongMeaning.validate().isNotEmpty) _buildInfoRow('English Long Meaning', word.englishLongMeaning ?? ''),
                    if (word.description.validate().isNotEmpty) _buildInfoRow('Description', word.description ?? ''),
                  ],
                );
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: tile,
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
          Text(label, style: boldTextStyle(size: 12, color: Colors.grey[600]!)),
          4.height,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(value, style: secondaryTextStyle()),
          ),
        ],
      ),
    );
  }
}
