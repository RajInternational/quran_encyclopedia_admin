import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordData.dart';
import 'package:quizeapp/screens/admin/dictionary/AddDictionaryWordScreen.dart';
import 'package:quizeapp/services/DictionaryWordService.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:quizeapp/utils/Colors.dart';

import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:quizeapp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/pagination/paginate_firestore.dart';
import 'package:quizeapp/pagination/bloc/pagination_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DictionaryWordsListScreen extends StatefulWidget {
  @override
  _DictionaryWordsListScreenState createState() =>
      _DictionaryWordsListScreenState();
}

class _DictionaryWordsListScreenState extends State<DictionaryWordsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  int _totalWords = 0;
  PaginationCubit? _paginationCubit;


  @override
  void initState() {
    super.initState();
    _loadTotalCount();

    // Listen for when returning from Add Dictionary Word screen
    LiveStream().on('refreshDictionaryWords', (data) {
      if (mounted) {
        _loadTotalCount();
        // With live mode enabled, the list should update automatically
      }
    });
  }

  Future<void> _loadTotalCount() async {
    try {
      final snapshot = await db.collection('dictionary_words').get();
      setState(() {
        _totalWords = snapshot.docs.length;
      });
    } catch (e) {
      print('Error loading total count: $e');
    }
  }

  Future<void> _deleteWord(DictionaryWordData word) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Word'),
          content: Text(
            'Are you sure you want to delete "${word.arabicWord}"?',
          ),
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
        await dictionaryWordService.deleteDictionaryWord(word.id);
        toast('Word deleted successfully!');
        // With live mode enabled, the list should update automatically
        // Just refresh the total count
        _loadTotalCount();
      } catch (e) {
        print(e);
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
    ).then((_) {
      // With live mode enabled, the list should update automatically
      // Just refresh the total count
      _loadTotalCount();
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
             create: (context) {
         _paginationCubit = PaginationCubit(
           db.collection('dictionary_words').orderBy('createdAt', descending: true),
           20,
           null,
           isLive: true, // Enable live updates
         );
         return _paginationCubit!;
       },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Dictionary Words',
            style: boldTextStyle(color: Colors.white),
          ),
          backgroundColor: colorPrimary,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                // Navigate to Add Dictionary Word screen using drawer navigation
                LiveStream().emit(
                  'selectItem',
                  3,
                ); // Index 3 is "Add Dictionary Word"
              },
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _performSearch,
                      decoration: InputDecoration(
                        hintText: 'Search Arabic words...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isSearching)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    tooltip: 'Clear Search',
                  ),
              ],
            ),
          ),

          // Statistics Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorPrimary, colorPrimary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorPrimary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.library_books,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Dictionary Words',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      4.height,
                      Text(
                        '$_totalWords',
                        style: boldTextStyle(size: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Paginated List
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildPaginatedList(),
          ),
        ],
      ),
    ));
  }

  Widget _buildPaginatedList() {
    // Build the query for pagination
    Query query = db
        .collection('dictionary_words')
        .orderBy('createdAt', descending: true);

    return Column(
      children: [
        // Pagination info header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Showing paginated results (20 words per page)',
            style: secondaryTextStyle(size: 12, color: Colors.grey[600]),
          ),
        ),
        // Paginated list
        Expanded(
                   child: PaginateFirestore(
           query: query,
           itemsPerPage: 20, // Load 20 items per page
           itemBuilderType: PaginateBuilderType.listView,
           isLive: true, // Enable live updates
            itemBuilder: (context, documentSnapshots, index) {
              final doc = documentSnapshots[index];
              final word = DictionaryWordData.fromJson(
                doc.data() as Map<String, dynamic>,
              );

              return _buildWordCard(word);
            },
            onEmpty: Container(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  16.height,
                  Text(
                    'No Dictionary Words',
                    style: boldTextStyle(size: 18, color: Colors.grey[600]),
                  ),
                  8.height,
                  Text(
                    'Add your first Arabic word to get started',
                    style: secondaryTextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  24.height,
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDictionaryWordScreen(),
                        ),
                                             ).then((_) {
                         // With live mode enabled, the list should update automatically
                         _loadTotalCount();
                       });
                    },
                    icon: Icon(Icons.add),
                    label: Text('Add First Word'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            initialLoader: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorPrimary),
                  16.height,
                  Text('Loading dictionary words...'),
                ],
              ),
            ),
            bottomLoader: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: colorPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<DictionaryWordData>>(
      future: dictionaryWordService.searchDictionaryWords(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorPrimary),
                16.height,
                Text('Searching...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                16.height,
                Text('Error searching words'),
                8.height,
                Text(snapshot.error.toString(), style: secondaryTextStyle()),
              ],
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                16.height,
                Text(
                  'No results found',
                  style: boldTextStyle(size: 18, color: Colors.grey[600]),
                ),
                8.height,
                Text(
                  'Try a different search term',
                  style: secondaryTextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Found ${results.length} result${results.length == 1 ? '' : 's'} for "$_searchQuery"',
                style: secondaryTextStyle(size: 14, color: Colors.grey[600]),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  return _buildWordCard(results[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWordCard(DictionaryWordData word) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.arabicWord ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'NotoNastaliq',
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                        textDirection: ui.TextDirection.rtl,
                      ),
                      4.height,
                      if (word.rootWord != null && word.rootWord!.isNotEmpty)
                        Text(
                          'Root: ${word.rootWord!}',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'NotoNastaliq',
                            color: Colors.purple[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textDirection: ui.TextDirection.rtl,
                        ),
                      8.height,
                      if (word.description != null &&
                          word.description!.isNotEmpty)
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
                      child: Icon(
                        Icons.translate,
                        color: colorPrimary,
                        size: 20,
                      ),
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    LiveStream().dispose('refreshDictionaryWords');
    _paginationCubit?.close();
    super.dispose();
  }
}
