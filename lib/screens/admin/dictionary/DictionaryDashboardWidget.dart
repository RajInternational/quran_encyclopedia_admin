import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordData.dart';
import 'package:quizeapp/screens/admin/dictionary/AddDictionaryWordScreen.dart';
import 'package:quizeapp/screens/admin/dictionary/DictionaryWordsListScreen.dart';
import 'package:quizeapp/services/DictionaryWordService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:intl/intl.dart';

class DictionaryDashboardWidget extends StatefulWidget {
  @override
  _DictionaryDashboardWidgetState createState() =>
      _DictionaryDashboardWidgetState();
}

class _DictionaryDashboardWidgetState extends State<DictionaryDashboardWidget> {
  final DictionaryWordService _dictionaryService = DictionaryWordService();
  List<DictionaryWordData> _recentWords = [];
  bool _isLoading = true;
  int _totalWords = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allWords = await _dictionaryService.dictionaryWordsFuture();
      setState(() {
        _totalWords = allWords.length;
        _recentWords = allWords.take(5).toList(); // Get 5 most recent words
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorPrimary),
                    16.height,
                    Text('Loading dictionary dashboard...'),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorPrimary, colorPrimary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorPrimary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.translate,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              16.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Arabic Dictionary',
                                      style: boldTextStyle(
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                    4.height,
                                    Text(
                                      'Manage your Arabic word collection',
                                      style: secondaryTextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          24.height,
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total Words',
                                  '$_totalWords',
                                  Icons.library_books,
                                  Colors.white,
                                  Colors.white.withOpacity(0.2),
                                ),
                              ),
                              16.width,
                              Expanded(
                                child: _buildStatCard(
                                  'Recent',
                                  '${_recentWords.length}',
                                  Icons.access_time,
                                  Colors.white,
                                  Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    24.height,

                    // Quick Actions
                    Text('Quick Actions', style: boldTextStyle(size: 20)),
                    16.height,
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            'Add New Word',
                            'Create a new dictionary entry',
                            Icons.add_circle,
                            Colors.green,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddDictionaryWordScreen(),
                              ),
                            ).then((_) => _loadDashboardData()),
                          ),
                        ),
                        16.width,
                        Expanded(
                          child: _buildActionCard(
                            'View All Words',
                            'Browse and manage all words',
                            Icons.list_alt,
                            Colors.blue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DictionaryWordsListScreen(),
                              ),
                            ).then((_) => _loadDashboardData()),
                          ),
                        ),
                      ],
                    ),
                    24.height,

                    // Recent Words
                    Row(
                      children: [
                        Text('Recent Words', style: boldTextStyle(size: 20)),
                        Spacer(),
                        TextButton(
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DictionaryWordsListScreen(),
                                ),
                              ).then((_) => _loadDashboardData()),
                          child: Text('View All'),
                        ),
                      ],
                    ),
                    16.height,

                    // Recent Words List
                    _recentWords.isEmpty
                        ? Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.translate_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              16.height,
                              Text(
                                'No words yet',
                                style: boldTextStyle(
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              8.height,
                              Text(
                                'Add your first Arabic word to get started',
                                style: secondaryTextStyle(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              24.height,
                              ElevatedButton.icon(
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                AddDictionaryWordScreen(),
                                      ),
                                    ).then((_) => _loadDashboardData()),
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
                        )
                        : Column(
                          children:
                              _recentWords
                                  .map((word) => _buildRecentWordCard(word))
                                  .toList(),
                        ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          8.height,
          Text(value, style: boldTextStyle(size: 20, color: iconColor)),
          4.height,
          Text(
            title,
            style: secondaryTextStyle(
              color: iconColor.withOpacity(0.8),
              size: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
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
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                12.height,
                Text(
                  title,
                  style: boldTextStyle(size: 16),
                  textAlign: TextAlign.center,
                ),
                4.height,
                Text(
                  subtitle,
                  style: secondaryTextStyle(size: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentWordCard(DictionaryWordData word) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.translate, color: colorPrimary, size: 20),
        ),
        title: Text(
          word.arabicWord ?? '',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'NotoNastaliq',
            fontWeight: FontWeight.w600,
            color: colorPrimary,
          ),
          textDirection: ui.TextDirection.rtl,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            4.height,
            if (word.description != null && word.description!.isNotEmpty)
              Text(
                word.description!,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'NotoNastaliq',
                  color: Colors.grey[600],
                ),
                textDirection: ui.TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            4.height,
            Text(
              'Created: ${word.createdAt != null ? DateFormat(CurrentDateFormat).format(word.createdAt!) : 'N/A'}',
              style: secondaryTextStyle(size: 10),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDictionaryWordScreen(wordToEdit: word),
              ),
            ).then((_) => _loadDashboardData()),
      ),
    );
  }
}
