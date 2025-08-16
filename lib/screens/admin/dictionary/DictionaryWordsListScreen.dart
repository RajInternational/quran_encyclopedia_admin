import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordData.dart';
import 'package:quizeapp/screens/admin/dictionary/AddDictionaryWordScreen.dart';
import 'package:quizeapp/services/DictionaryWordService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:intl/intl.dart';

class DictionaryWordsListScreen extends StatefulWidget {
  @override
  _DictionaryWordsListScreenState createState() => _DictionaryWordsListScreenState();
}

class _DictionaryWordsListScreenState extends State<DictionaryWordsListScreen> {
  final DictionaryWordService _dictionaryService = DictionaryWordService();
  final TextEditingController _searchController = TextEditingController();
  
  List<DictionaryWordData> _allWords = [];
  List<DictionaryWordData> _filteredWords = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadDictionaryWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDictionaryWords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final words = await _dictionaryService.dictionaryWordsFuture();
      setState(() {
        _allWords = words;
        _filteredWords = words;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      toast('Error loading dictionary words: ${e.toString()}');
    }
  }

  void _filterWords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWords = _allWords;
      } else {
        _filteredWords = _allWords.where((word) {
          return word.arabicWord?.toLowerCase().contains(query.toLowerCase()) == true ||
                 word.description?.toLowerCase().contains(query.toLowerCase()) == true;
        }).toList();
      }
    });
  }

  Future<void> _deleteWord(DictionaryWordData word) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              8.width,
              Text('Delete Word'),
            ],
          ),
          content: Text('Are you sure you want to delete "${word.arabicWord}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _dictionaryService.deleteDictionaryWord(word.id);
        toast('Word deleted successfully!');
        _loadDictionaryWords();
      } catch (e) {
        toast('Error deleting word: ${e.toString()}');
      }
    }
  }

  void _editWord(DictionaryWordData word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDictionaryWordScreen(wordToEdit: word),
      ),
    ).then((_) => _loadDictionaryWords());
  }

  void _addNewWord() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDictionaryWordScreen(),
      ),
    ).then((_) => _loadDictionaryWords());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        title: Text(
          'Dictionary Words',
          style: boldTextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _addNewWord,
            tooltip: 'Add New Word',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterWords,
                decoration: InputDecoration(
                  hintText: 'Search Arabic words...',
                  prefixIcon: Icon(Icons.search, color: colorPrimary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filterWords('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Statistics Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.purple[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.translate, color: colorPrimary, size: 24),
                ),
                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Words',
                        style: secondaryTextStyle(size: 12),
                      ),
                      4.height,
                      Text(
                        '${_filteredWords.length}',
                        style: boldTextStyle(size: 24, color: colorPrimary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Dictionary',
                    style: boldTextStyle(size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Words List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: colorPrimary),
                        16.height,
                        Text('Loading dictionary words...'),
                      ],
                    ),
                  )
                : _filteredWords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.translate_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            16.height,
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No dictionary words found'
                                  : 'No words match your search',
                              style: boldTextStyle(size: 18, color: Colors.grey[600]),
                            ),
                            8.height,
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Add your first Arabic word to get started'
                                  : 'Try a different search term',
                              style: secondaryTextStyle(color: Colors.grey[500]),
                            ),
                            24.height,
                            if (_searchController.text.isEmpty)
                              ElevatedButton.icon(
                                onPressed: _addNewWord,
                                icon: Icon(Icons.add),
                                label: Text('Add First Word'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorPrimary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredWords.length,
                        itemBuilder: (context, index) {
                          final word = _filteredWords[index];
                          return _buildWordCard(word);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(DictionaryWordData word) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editWord(word),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.arabicWord ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'NotoNastaliq',
                              fontWeight: FontWeight.w600,
                              color: colorPrimary,
                            ),
                                                          textDirection: ui.TextDirection.rtl,
                          ),
                          8.height,
                          if (word.description != null && word.description!.isNotEmpty)
                            Text(
                              word.description!,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoNastaliq',
                                height: 1.4,
                                color: Colors.grey[700],
                              ),
                              textDirection: ui.TextDirection.rtl,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    16.width,
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.translate, color: colorPrimary, size: 20),
                        ),
                        8.height,
                        if (word.reference != null && word.reference!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(Icons.image, color: Colors.green, size: 16),
                          ),
                      ],
                    ),
                  ],
                ),
                16.height,
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    4.width,
                    Text(
                                             'Created: ${word.createdAt != null ? DateFormat(CurrentDateFormat).format(word.createdAt!) : 'N/A'}',
                      style: secondaryTextStyle(size: 12),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => _editWord(word),
                      icon: Icon(Icons.edit, color: colorPrimary, size: 20),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteWord(word),
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
