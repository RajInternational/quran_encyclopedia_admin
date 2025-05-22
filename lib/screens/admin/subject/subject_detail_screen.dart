import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/screens/admin/subject/update_ayat_screen.dart';
import 'package:quizeapp/screens/admin/subject/view_ayat.dart';
import '../../../main.dart';
import '../../../utils/Colors.dart';

class SubjectDetailScreen extends StatefulWidget {
  const SubjectDetailScreen({Key? key}) : super(key: key);

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  bool loading = false;
  int startPage = 1;
  int selectedPage = 1;
  int currentPage = 1;
  static const int itemsPerPage = 8;

  DocumentSnapshot? _lastDocument;
  int subjectCount = 0;
  bool _isMounted = false;

  TextEditingController _pageController = TextEditingController();

  Map<String, List<dynamic>> ayats = {};
  List<DateTime> timestamps = [];

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadData();
    });
  }

  Future<void> _showDeleteDialog(String subjectId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Subject'),
          content: Text('Are you sure you want to delete this subject?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSubject(subjectId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSubject(String subjectId) async {
    try {
      await db
          .collection('Book')
          .doc('Quran')
          .collection('SubjectCollection')
          .doc(subjectId)
          .delete();

      await _updateSubjectCounts();

      final data = ayats.remove(subjectId);
      setState(() {});

      toast('Subject deleted successfully');
    } catch (e, stackTrace) {
      print("Error deleting subject: $stackTrace");
      toast('Error deleting subject: $e');
    }
  }

  Future<void> _updateSubjectCounts() async {
    final subjectCollection = db
        .collection('Book')
        .doc('Quran')
        .collection('SubjectCollection')
        .orderBy('count');
    final querySnapshot = await subjectCollection.get();

    int count = 1;
    for (final doc in querySnapshot.docs) {
      await doc.reference.update({'count': count});
      count++;
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
    });

    try {
      ayats.clear();

      // First, get the total count of subjects
      final tempSubjectCollection = db
          .collection('Book')
          .doc('Quran')
          .collection('SubjectCollection');
      final countSnapshot = await tempSubjectCollection.get();
      subjectCount = countSnapshot.docs.length;


      final startAtValue = ((selectedPage - 1) * itemsPerPage) + 1;

      print('Loading page: $selectedPage');
      print('Start at count: $startAtValue');
      print('Items per page: $itemsPerPage');
      print('Total subjects: $subjectCount');

      // Build the query with proper pagination
      Query subjectQuery = db
          .collection('Book')
          .doc('Quran')
          .collection('SubjectCollection')
          .orderBy("count")
          .startAt([startAtValue])
          .limit(itemsPerPage);

      final QuerySnapshot querySnapshot = await subjectQuery.get();

      print('Fetched ${querySnapshot.docs.length} subjects for page $selectedPage');

      // Process each subject document
      for (final doc in querySnapshot.docs) {
        final tempSub = doc.data() as Map<String, dynamic>;
        print('Processing subject: ${tempSub['subjectName']} (count: ${tempSub['count']})');

        // Get ayats for this subject
        final ayatsQuery = await db
            .collection('Book')
            .doc('Quran')
            .collection('SubjectCollection')
            .doc(doc.id)
            .collection('ayats')
            .get();

        List<Map<String, dynamic>> ayatDataList = [];
        for (final ayatDoc in ayatsQuery.docs) {
          final ayatData = {
            'id': ayatDoc.id,
            'data': ayatDoc.data()
          };
          ayatDataList.add({
            "SubjectData": tempSub,
            "ayatData": ayatData
          });
        }

        if (ayatDataList.isNotEmpty) {
          ayats[doc.id] = ayatDataList;
        }
      }

    } catch (e, stackTrace) {
      print("Error fetching data: $e");
      print("Stack trace: $stackTrace");
    } finally {
      if (_isMounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subject Detail')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : _buildAyatList(),
    );
  }

  Widget _buildAyatList() {
    final subjects = ayats.keys.toList();

    return Column(
      children: [
        // Add pagination info display
        Container(
          padding: EdgeInsets.all(8),
          child: Text(
            'Page $selectedPage of ${(subjectCount / itemsPerPage).ceil()} - Showing ${subjects.length} subjects (Total: $subjectCount)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: subjects.isEmpty
              ? Center(child: Text('No data available'))
              : ListView(
            children: List.generate(subjects.length, (index) {
              final key = subjects[index];
              final ayatList = ayats[key] ?? [];
              if (ayatList.isEmpty) {
                return SizedBox.shrink();
              }
              final subject = ayatList[0]['SubjectData']['subjectName'];
              final subjectId = ayatList[0]['SubjectData']['subjectId'];
              final subjectCount = ayatList[0]['SubjectData']['count'];

              if (subject == null) {
                return SizedBox.shrink();
              }

              return Container(
                decoration: BoxDecoration(
                  boxShadow: defaultBoxShadow(),
                  color: Colors.white,
                  borderRadius: radius(),
                ),
                margin: EdgeInsets.only(bottom: 16, top: 16, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          decoration: boxDecorationWithRoundedCorners(
                            border: Border.all(
                              color: gray.withOpacity(0.4),
                              width: 0.1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${subjectCount}.  $subject',
                                style: GoogleFonts.notoNastaliqUrdu(
                                  color: colorPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // Text(
                              //   'Page item: ${index + 1}',
                              //   style: TextStyle(
                              //     fontSize: 10,
                              //     color: Colors.grey,
                              //   ),
                              // ),
                            ],
                          ),
                        ).expand(),
                        16.width,
                        IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            color: black,
                          ),
                          onPressed: () async {
                            await _showDeleteDialog(subjectId);
                          },
                        ).paddingOnly(right: 8),
                        IconButton(
                          icon: Icon(Icons.open_in_new, color: black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewAyat(ayats: ayatList),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateAyatScreen(
                                  subjectId: subjectId,
                                  ayats: ayatList,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    16.height,
                  ],
                ),
              );
            }),
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (subjectCount / itemsPerPage).ceil();

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Previous page button
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20),
            onPressed: selectedPage > 1
                ? () async {
              selectedPage--;
              await _loadData();
              setState(() {});
            }
                : null,
          ),

          // Page numbers - show current page and nearby pages
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Show first page if not visible
                  if (currentPage > 1) ...[
                    _buildPageButton(1),
                    if (currentPage > 2) Text('...'),
                  ],

                  // Show current page range
                  for (int i = currentPage; i <= currentPage + 7 && i <= totalPages; i++)
                    _buildPageButton(i),

                  // Show last page if not visible
                  if (currentPage + 7 < totalPages) ...[
                    if (currentPage + 8 < totalPages) Text('...'),
                    _buildPageButton(totalPages),
                  ],
                ],
              ),
            ),
          ),

          // Next page button
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: selectedPage < totalPages
                ? () async {
              selectedPage++;
              // Update currentPage if we've moved beyond the visible range
              if (selectedPage > currentPage + 7) {
                currentPage = selectedPage;
              }
              await _loadData();
              setState(() {});
            }
                : null,
          ),

          // Jump to page field
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
                    String input = _pageController.text.trim();
                    if (input.isNotEmpty) {
                      int? pageNumber = int.tryParse(input);
                      if (pageNumber != null &&
                          pageNumber >= 1 &&
                          pageNumber <= totalPages) {
                        setState(() {
                          selectedPage = pageNumber;
                          currentPage = ((pageNumber - 1) ~/ 8) * 8 + 1;
                        });
                        await _loadData();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: GestureDetector(
        onTap: () async {
          selectedPage = pageNumber;
          await _loadData();
          setState(() {});
        },
        child: CircleAvatar(
          radius: 16,
          backgroundColor: pageNumber == selectedPage ? Colors.green : Colors.grey[300],
          child: Text(
            '$pageNumber',
            style: TextStyle(
              color: pageNumber == selectedPage ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
