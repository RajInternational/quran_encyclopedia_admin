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
  int totalSujectCount = 7342;

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
      final startAtValue = ((selectedPage - 1) * 8) + 1;
      final endBeforeValue = (selectedPage * 8) + 1;
      print('Check start $startAtValue');
      print('Check end $endBeforeValue');

      final tempSubjectCollection = db
          .collection('Book')
          .doc('Quran')
          .collection('SubjectCollection');
      final querySnapshot = await tempSubjectCollection.get();
      subjectCount = querySnapshot.docs.length;
      final subjectCollection = db
          .collection('Book')
          .doc('Quran')
          .collection('SubjectCollection')
          .orderBy("count")
          .startAt([startAtValue])
          .endBefore([endBeforeValue])
          .limit(9);
      final data = await subjectCollection.get();

      print("check Count:${data.size}");
      final collection = await db
          .collection('Book')
          .doc('Quran')
          .collection('SubjectCollection');
      // .limit(2);

      // Fetch data from Firestore
      await subjectCollection.get().then((QuerySnapshot querySnapshot) async {
        for (final doc in querySnapshot.docs) {
          final tempSub = doc.data() as Map<String, dynamic>;
          print('yvggrvrv ${querySnapshot.docs.length}');
          final query = await collection.doc(doc.id).collection('ayats').get();
          List<Map<String, dynamic>> data = [];
          for (final ayatDoc in query.docs) {
            final id = ayatDoc.id;
            // log('DATA: ${ayatDoc.data()}');
            Map<String, dynamic> ayatData = {'id': id, 'data': ayatDoc.data()};
            data.add({"SubjectData": tempSub, "ayatData": ayatData});
          }
          ayats[doc.id] = data;
        }
        if (_isMounted) {
          setState(() {});
        }
      });
    } catch (e) {
      // Handle error
      print("Error fetching data: $e");
    } finally {
      // Update loading state
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
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : _buildAyatList(),
    );
  }

  Widget _buildAyatList() {
    final subjects = ayats.keys.toList();

    return Column(
      children: [
        Expanded(
          child:
              subjects.isEmpty
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
                                  child: Text(
                                    '${index + 1}. $subject',
                                    style: GoogleFonts.notoNastaliqUrdu(
                                      color: colorPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
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
                                        builder:
                                            (context) =>
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
                                        builder:
                                            (context) => UpdateAyatScreen(
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
        Container(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () async {
                  if (selectedPage > 1) {
                    selectedPage--;
                    await _loadData();
                  }
                  setState(() {});
                },
              ),
              // Page numbers
              for (int i = currentPage; i <= currentPage + 8; i++)
                if (i <= (subjectCount / 8).ceil())
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: GestureDetector(
                      onTap: () async {
                        selectedPage = i;

                        await _loadData();
                        setState(() {});
                      },
                      child: CircleAvatar(
                        backgroundColor:
                            i == selectedPage ? Colors.green : Colors.white,
                        child: Text(
                          '$i',
                          style: TextStyle(
                            color:
                                i == selectedPage ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              // Next ten pages arrow
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: () {
                  if (currentPage + 8 <= (subjectCount / 8).ceil()) {
                    setState(() {
                      currentPage += 8;
                    });
                  }
                },
              ),
              // Last page arrow
              Container(
                width: 100,
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Go to page',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Go button
                    TextButton(
                      onPressed: () async {
                        String input = _pageController.text.trim();

                        if (input.isNotEmpty) {
                          int? pageNumber = int.tryParse(input);
                          if (pageNumber != null &&
                              pageNumber >= 1 &&
                              pageNumber <= (subjectCount / 8).ceil()) {
                            setState(() {
                              startPage = pageNumber;
                              currentPage = pageNumber;
                              selectedPage = pageNumber;
                            });

                            await _loadData();
                          }
                        }
                      },
                      child: Text('Go'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
