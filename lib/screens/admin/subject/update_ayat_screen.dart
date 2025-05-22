import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/utils/Colors.dart';

import '../../../main.dart';
import '../../../utils/Common.dart';
import '../AdminDashboardScreen.dart';

class UpdateAyatScreen extends StatefulWidget {
  final String subjectId;
  final List<dynamic> ayats;

  UpdateAyatScreen({required this.subjectId, required this.ayats});

  @override
  _UpdateAyatScreenState createState() => _UpdateAyatScreenState();
}

class _UpdateAyatScreenState extends State<UpdateAyatScreen> {
  List<dynamic> ayatsList = [];
  TextEditingController subjectController = TextEditingController();
  TextEditingController tempSubjectController = TextEditingController();

  TextEditingController ayatNoController = TextEditingController();
  TextEditingController arabicController = TextEditingController();
  List<TextEditingController> newAyatParaControllers = [];
  List<TextEditingController> ayatControllers = [];
  List<TextEditingController> ayatArabicControllers = [];
  bool showFields = false;
  Future<Map<String, dynamic>> getSubjectData(String docId) async {
    print("id $docId");
    final subjectCollection = FirebaseFirestore.instance
        .collection("Book")
        .doc("Quran")
        .collection("SubjectCollection");
    final testingData = await subjectCollection.doc(docId).get();
    return testingData.data() as Map<String, dynamic>;
  }

  Map<String, dynamic>? subjectData;

  Future<void> _init() async {
    subjectData = await getSubjectData(widget.subjectId);
    subjectController.text = subjectData!['subjectName'];
    print("subject$subjectData");
  }

  @override
  void initState() {
    super.initState();
    ayatsList.addAll(widget.ayats);
    _init();

    // Initialize controllers for each ayat
    for (var i = 0; i < ayatsList.length; i++) {
      ayatControllers.add(
          TextEditingController(text: ayatsList[i]["ayatData"]["data"]['no']));
      ayatArabicControllers.add(
        TextEditingController(
            text: ayatsList[i]["ayatData"]["data"]['arabic'].toString()),
      );
      // String id = widget.ayats[i]['id']['id'];
      // print('ID of Ayat $i: $id');
    }
    widget.ayats.sort((a, b) {
      final ayatNoA =
          double.tryParse(a['ayatData']['data']['index'].toString()) ?? 0;
      final ayatNoB =
          double.tryParse(b['ayatData']['data']['index'].toString()) ?? 0;
      return ayatNoA.compareTo(ayatNoB);
    });
  }

  Future<void> subUpdate() async {
    print("check Id : ${subjectData!['subjectId']}");
    await db
        .collection("Book")
        .doc("Quran")
        .collection("SubjectCollection")
        .doc(subjectData!['subjectId'])
        .update({
      'subjectName': subjectController.text.trim(),
    });
  }

  Future<void> _showDeleteAyatDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text('Are you sure you want to delete?'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                // Delete the ayat
                await deleteData(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteData(int index) async {
    String id = ayatsList[index]["ayatData"]['id'];
    ayatsList.removeAt(index);
    setState(() {
      ayatControllers.removeAt(index);
      ayatArabicControllers.removeAt(index);
    });
    await FirebaseFirestore.instance
        .collection("Book")
        .doc("Quran")
        .collection("SubjectCollection")
        .doc(subjectData!['subjectId'])
        .collection("ayats")
        .doc(id)
        .delete();
    setState(() {});
    print("length after ${ayatsList.length}");
  }

  Future<void> setData() async {
    final batch = db.batch();
    try {
      if (newAyatParaControllers.isNotEmpty) {
        for (int i = 0; i < newAyatParaControllers.length; i++) {
          String ayatNo = newAyatParaControllers[i].text;
          final snapshot = await FirebaseFirestore.instance
              .collection("Book")
              .doc("Quran")
              .collection("CompleteQuran")
              .where('no', isEqualTo: ayatNo)
              .get();

          if (snapshot.docs.isNotEmpty) {
            print("check Data: ${snapshot.docs.first.data()}");
            final data = db
                .collection("Book")
                .doc("Quran")
                .collection("SubjectCollection");

            for (int j = 0; j < snapshot.docs.length; j++) {
              print("indexxxxx ${j}");
              final ref =
                  data.doc(subjectData!['subjectId']).collection("ayats").doc();

              Map<String, dynamic> updatedData = snapshot.docs[j].data();

              updatedData['index'] = j;
              batch.set(
                ref,
                updatedData,
              );
            }
            print("check Id : ${subjectData!['subjectId']}");
          } else {
            print("No data found for ayat number $ayatNo");
          }
        }
      }

      final subjectSnapshot = await db
          .collection("Book")
          .doc("Quran")
          .collection("SubjectCollection")
          .doc(subjectData!['subjectId'])
          .collection("ayats")
          .get();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
          subjectSnapshot.docs;
      docs.sort((a, b) => a.data()['no'].compareTo(b.data()['no']));

      for (int i = 0; i < docs.length; i++) {
        final docRef = docs[i].reference;
        print("heeeeee${i}");
        batch.update(docRef, {'index': i});
      }
    } catch (e, stackTrace) {
      print('New Error ${e.toString()}');
      print("Error ${stackTrace.toString()}");
    }
    await batch.commit();
  }

  Future<void> fetchData() async {
    final batch = db.batch();
    for (int i = 0; i < ayatsList.length; i++) {
      // print("check Id : ${widget.ayats[i]}");
      String id = ayatsList[i]["ayatData"]['id'];
      print("check new Id : $id");
      String subject = subjectController.text;
      String ayatNo = ayatControllers[i].text;

      final snapshot = await FirebaseFirestore.instance
          .collection("Book")
          .doc("Quran")
          .collection("CompleteQuran")
          .where('no', isEqualTo: ayatNo)
          .get();
      if (snapshot.docs.isNotEmpty) {
        print("check Data: ${snapshot.docs.first.data()}");
        final data =
            db.collection("Book").doc("Quran").collection("SubjectCollection");
        final ref =
            data.doc(subjectData!['subjectId']).collection("ayats").doc(id);
        batch.update(
          ref,
          snapshot.docs.first.data(),
        );
      } else {
        print("No data found for ayat number $ayatNo");
      }
    }

    await batch.commit();
  }

  @override
  void dispose() {
    super.dispose();
    subjectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Ayat'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject:',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            TextFormField(
              controller: subjectController,
              decoration: InputDecoration(
                hintText: 'Enter subject',
                border: OutlineInputBorder(),
              ),
            ),
            10.height,
            Align(
              alignment: Alignment.bottomRight,
              child: AppButton(
                color: colorPrimary,
                onTap: () {
                  setState(() {
                    showFields = true;
                    newAyatParaControllers.add(TextEditingController());
                  });
                },
                child: Text(
                  'Add More Fields',
                  style: primaryTextStyle(
                    color: white,
                  ),
                ),
              ),
            ),
            if (showFields)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: newAyatParaControllers.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AppTextField(
                              controller: newAyatParaControllers[index],
                              textFieldType: TextFieldType.NUMBER,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 1,
                              minLines: 1,
                              decoration: inputDecoration(
                                labelText:
                                    'Type Surah No & Ayat No like this (1.2)',
                              ),
                              validator: (s) {
                                return null;
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              newAyatParaControllers.removeAt(index);
                              if (newAyatParaControllers.isEmpty) {
                                showFields = false;
                              }
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            SizedBox(height: 16),
            Text(
              'Ayat:',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ayatsList.length,
                itemBuilder: (context, index) {
                  print("check index$index");
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: ayatControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Ayat No',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            style: GoogleFonts.notoNastaliqUrdu(),
                            controller: ayatArabicControllers[index],
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Ayat',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteAyatDialog(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),
            AppButton(
              color: colorPrimary,
              child: Text("Update", style: primaryTextStyle(color: white)),
              onTap: () async {
                await subUpdate();
                await fetchData();
                await setData();

                toast("update Successfully");
                AdminDashboardScreen().launch(context, isNewTask: true);
              },
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     fetchData();
            //     toast("update Successfully");
            //     AdminDashboardScreen().launch(context, isNewTask: true);
            //   },
            //   child: Text('Update'),
            // ),
          ],
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:quizeapp/utils/Colors.dart';
//
// import '../../../main.dart';
// import '../../../utils/Common.dart';
// import '../AdminDashboardScreen.dart';
//
// class UpdateAyatScreen extends StatefulWidget {
//   final String subjectId;
//   final List<dynamic> ayats;
//
//   UpdateAyatScreen({required this.subjectId, required this.ayats});
//
//   @override
//   _UpdateAyatScreenState createState() => _UpdateAyatScreenState();
// }
//
// class _UpdateAyatScreenState extends State<UpdateAyatScreen> {
//   List<dynamic> ayatsList = [];
//   TextEditingController subjectController = TextEditingController();
//   TextEditingController tempSubjectController = TextEditingController();
//
//   TextEditingController ayatNoController = TextEditingController();
//   TextEditingController arabicController = TextEditingController();
//   List<TextEditingController> newAyatParaControllers = [];
//   List<TextEditingController> ayatControllers = [];
//   List<TextEditingController> ayatArabicControllers = [];
//   bool showFields = false;
//   Future<Map<String, dynamic>> getSubjectData(String docId) async {
//     print("id $docId");
//     final subjectCollection = FirebaseFirestore.instance
//         .collection("Book")
//         .doc("Quran")
//         .collection("SubjectCollection");
//     final testingData = await subjectCollection.doc(docId).get();
//     return testingData.data() as Map<String, dynamic>;
//   }
//
//   Map<String, dynamic>? subjectData;
//
//   Future<void> _init() async {
//     subjectData = await getSubjectData(widget.subjectId);
//     subjectController.text = subjectData!['subjectName'];
//     print("subject$subjectData");
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     ayatsList.addAll(widget.ayats);
//     _init();
//
//     // Initialize controllers for each ayat
//     for (var i = 0; i < ayatsList.length; i++) {
//       ayatControllers.add(
//           TextEditingController(text: ayatsList[i]["ayatData"]["data"]['no']));
//       ayatArabicControllers.add(
//         TextEditingController(
//             text: ayatsList[i]["ayatData"]["data"]['arabic'].toString()),
//       );
//       // String id = widget.ayats[i]['id']['id'];
//       // print('ID of Ayat $i: $id');
//     }
//     widget.ayats.sort((a, b) {
//       final ayatNoA =
//           double.tryParse(a['ayatData']['data']['index'].toString()) ?? 0;
//       final ayatNoB =
//           double.tryParse(b['ayatData']['data']['index'].toString()) ?? 0;
//       return ayatNoA.compareTo(ayatNoB);
//     });
//   }
//
//   Future<void> subUpdate() async {
//     print("check Id : ${subjectData!['subjectId']}");
//     await db
//         .collection("Book")
//         .doc("Quran")
//         .collection("SubjectCollection")
//         .doc(subjectData!['subjectId'])
//         .update({
//       'subjectName': subjectController.text.trim(),
//     });
//   }
//
//   Future<void> _showDeleteAyatDialog(int index) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SingleChildScrollView(
//             child: Text('Are you sure you want to delete?'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Yes'),
//               onPressed: () async {
//                 // Delete the ayat
//                 await deleteData(index);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> deleteData(int index) async {
//     String id = ayatsList[index]["ayatData"]['id'];
//     ayatsList.removeAt(index);
//     setState(() {
//       ayatControllers.removeAt(index);
//       ayatArabicControllers.removeAt(index);
//     });
//     await FirebaseFirestore.instance
//         .collection("Book")
//         .doc("Quran")
//         .collection("SubjectCollection")
//         .doc(subjectData!['subjectId'])
//         .collection("ayats")
//         .doc(id)
//         .delete();
//     setState(() {});
//     print("length after ${ayatsList.length}");
//   }
//
//   Future<void> setData() async {
//     final batch = db.batch();
//     try {
//       if (newAyatParaControllers.isNotEmpty) {
//         for (int i = 0; i < newAyatParaControllers.length; i++) {
//           // print("check Id : ${ayatsList[i]}");
//           String ayatNo = newAyatParaControllers[i].text;
//           final snapshot = await FirebaseFirestore.instance
//               .collection("Book")
//               .doc("Quran")
//               .collection("CompleteQuran")
//               .where('no', isEqualTo: ayatNo)
//               .get();
//           if (snapshot.docs.isNotEmpty) {
//             print("check Data: ${snapshot.docs.first.data()}");
//             final data = db
//                 .collection("Book")
//                 .doc("Quran")
//                 .collection("SubjectCollection");
//             for (int j = 0; j < snapshot.docs.length; j++) {
//               final ref =
//                   data.doc(subjectData!['subjectId']).collection("ayats").doc();
//               batch.set(
//                 ref,
//                 snapshot.docs[j].data(),
//               );
//             }
//             print("check Id : ${subjectData!['subjectId']}");
//           } else {
//             print("No data found for ayat number $ayatNo");
//           }
//         }
//       }
//     } catch (e, stackTrace) {
//       print('New Error ${e.toString()}');
//       print("Error ${stackTrace.toString()}");
//     }
//     await batch.commit();
//   }
//
//   Future<void> fetchData() async {
//     final batch = db.batch();
//     for (int i = 0; i < ayatsList.length; i++) {
//       // print("check Id : ${widget.ayats[i]}");
//       String id = ayatsList[i]["ayatData"]['id'];
//       print("check new Id : $id");
//       String subject = subjectController.text;
//       String ayatNo = ayatControllers[i].text;
//
//       final snapshot = await FirebaseFirestore.instance
//           .collection("Book")
//           .doc("Quran")
//           .collection("CompleteQuran")
//           .where('no', isEqualTo: ayatNo)
//           .get();
//       if (snapshot.docs.isNotEmpty) {
//         print("check Data: ${snapshot.docs.first.data()}");
//         final data =
//             db.collection("Book").doc("Quran").collection("SubjectCollection");
//         final ref =
//             data.doc(subjectData!['subjectId']).collection("ayats").doc(id);
//         batch.update(
//           ref,
//           snapshot.docs.first.data(),
//         );
//       } else {
//         print("No data found for ayat number $ayatNo");
//       }
//     }
//
//     await batch.commit();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     subjectController.dispose();
//   }
//
//   void _addNewField() {
//     setState(() {
//       showFields = true;
//       newAyatParaControllers.add(TextEditingController());
//     });
//   }
//
//   void _addNewAyat() {
//     String newAyat = newAyatParaControllers.last.text;
//
//     ayatsList.add({
//       "ayatData": {
//         "data": {
//           "no": newAyat.split(".")[0],
//           "index": double.parse(newAyat),
//           "arabic": "",
//         },
//         "id": DateTime.now().millisecondsSinceEpoch.toString(),
//       }
//     });
//
//     ayatsList.sort((a, b) {
//       final ayatNoA =
//           double.tryParse(a["ayatData"]["data"]["index"].toString()) ?? 0;
//       final ayatNoB =
//           double.tryParse(b["ayatData"]["data"]["index"].toString()) ?? 0;
//       return ayatNoA.compareTo(ayatNoB);
//     });
//
//     // Update controllers to match sorted ayatsList
//     ayatControllers = List<TextEditingController>.generate(
//       ayatsList.length,
//       (index) => TextEditingController(
//           text: ayatsList[index]["ayatData"]["data"]["no"]),
//     );
//     ayatArabicControllers = List<TextEditingController>.generate(
//       ayatsList.length,
//       (index) => TextEditingController(
//           text: ayatsList[index]["ayatData"]["data"]["arabic"]),
//     );
//
//     // Clear newAyatParaControllers
//     newAyatParaControllers.clear();
//     showFields = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update Ayat'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Subject:',
//               style: TextStyle(
//                 fontSize: 18,
//               ),
//             ),
//             TextFormField(
//               controller: subjectController,
//               decoration: InputDecoration(
//                 hintText: 'Enter subject',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             10.height,
//             Align(
//               alignment: Alignment.bottomRight,
//               child: AppButton(
//                 color: colorPrimary,
//                 onTap: _addNewField,
//                 child: Text(
//                   'Add More Fields',
//                   style: primaryTextStyle(
//                     color: white,
//                   ),
//                 ),
//               ),
//             ),
//             if (showFields)
//               Expanded(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: newAyatParaControllers.length,
//                   itemBuilder: (context, index) {
//                     return Row(
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: AppTextField(
//                               controller: newAyatParaControllers[index],
//                               textFieldType: TextFieldType.NUMBER,
//                               textCapitalization: TextCapitalization.sentences,
//                               maxLines: 1,
//                               minLines: 1,
//                               decoration: inputDecoration(
//                                 labelText:
//                                     'Type Surah No & Ayat No like this (1.2)',
//                               ),
//                               validator: (s) {
//                                 return null;
//                               },
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.clear),
//                           onPressed: () {
//                             setState(() {
//                               newAyatParaControllers.removeAt(index);
//                               if (newAyatParaControllers.isEmpty) {
//                                 showFields = false;
//                               }
//                             });
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.check),
//                           onPressed: _addNewAyat,
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             SizedBox(height: 16),
//             Text(
//               'Ayat:',
//               style: TextStyle(
//                 fontSize: 18,
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: ayatsList.length,
//                 itemBuilder: (context, index) {
//                   print("check index$index");
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             controller: ayatControllers[index],
//                             decoration: InputDecoration(
//                               hintText: 'Ayat No',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           flex: 3,
//                           child: TextFormField(
//                             style: GoogleFonts.notoNastaliqUrdu(),
//                             controller: ayatArabicControllers[index],
//                             maxLines: 3,
//                             decoration: InputDecoration(
//                               hintText: 'Ayat',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             _showDeleteAyatDialog(index);
//                           },
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16),
//             AppButton(
//               color: colorPrimary,
//               child: Text("Update", style: primaryTextStyle(color: white)),
//               onTap: () async {
//                 await subUpdate();
//                 await fetchData();
//                 await setData();
//
//                 toast("Update Successfully");
//                 AdminDashboardScreen().launch(context, isNewTask: true);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
