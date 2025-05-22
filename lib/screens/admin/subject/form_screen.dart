import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';

import '../../../utils/Colors.dart';
import '../../../utils/Common.dart';
import '../AdminDashboardScreen.dart';

class FormScreen extends StatefulWidget {
  // final bool isUpdate;
  // final String? subject;
  // final List<dynamic>? ayats;

  FormScreen({
    Key? key,
    // this.ayats,
    // this.subject,
    // required this.isUpdate,
  }) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  var formKey = GlobalKey<FormState>();
  bool isUpdate = false;
  final TextEditingController? subjectController = TextEditingController();
  List<TextEditingController> ayatParaControllers = [TextEditingController()];
  List<String> ayatParaList = [];
  List<Map<String, dynamic>> saveData = [];
  bool isSave = false;
  Future<void> fetchData() async {
    // final snapshot = await FirebaseFirestore.instance
    //     .collection("Book")
    //     .doc("Quran")
    //     .collection("CompleteQuran")
    //     .where(
    //       'no',
    //       whereIn: ayatParaList,
    //     )
    //     .get();
    // for (int i = 0; i < snapshot.docs.length; i++) {
    //   saveData.add(snapshot.docs[i].data());
    // }
    QuerySnapshot<Map<String, dynamic>>? snapshot;

    if (isSave) {
      saveData.clear();
      snapshot = await FirebaseFirestore.instance
          .collection("Book")
          .doc("Quran")
          .collection("CompleteQuran")
          .where(
            'no',
            whereIn: ayatParaList,
          )
          .get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data();
        final ayatNumber = ayatParaControllers[i].text;
        final ayat = snapshot.docs.indexWhere((element) {
          return element.data()['no'] == ayatNumber;
        });
        data['index'] = ayat;
        saveData.add(data);
        print("index ayat ${ayat} $ayatNumber");
        print('data is ${data}');
        // saveData.add(snapshot.docs[i].data());
      }

      newData(subjectController!.text);
      // print("subject ${subjectController!.text}");
      // print("snapshot subject ${snapshot}");

      // for (int i = 0; i < snapshot!.docs.length; i++) {
      //   print("checkvalue $i ${saveData[i]}");
      // }
    } else {
      saveData.clear();

      snapshot = await FirebaseFirestore.instance
          .collection("Book")
          .doc("Quran")
          .collection("CompleteQuran")
          .where(
            'no',
            whereIn: ayatParaList,
          )
          .get();
      for (int i = 0; i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data();
        final ayatNumber = ayatParaControllers[i].text;
        final ayat = snapshot.docs.indexWhere((element) {
          return element.data()['no'] == ayatNumber;
        });
        data['index'] = ayat;
        saveData.add(data);
        print("index ayat ${ayat} $ayatNumber");
        print('data is ${data}');
        // saveData.add(snapshot.docs[i].data());
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> newData(String subject) async {
    try {
      final batch = db.batch();
      if (saveData.isNotEmpty) {
        final subjectCollection = FirebaseFirestore.instance
            .collection("Book")
            .doc("Quran")
            .collection("SubjectCollection");
        // final testingData = await subjectCollection.get();
        // print('my testing data ${testingData.docs.first.data()}');
        final a = await subjectCollection.count().get();
        log("Count${a.count}");
        final uid = subjectCollection.doc().id;
        print("new ID${uid}");
        // final id = '${uid}';
        await subjectCollection.doc(uid).set({
          "timestamp": DateTime.timestamp(),
          "count": a.count != null ? a.count! + 1 : 0,
          "subjectId": "${uid}",
          "subjectName": "${subject}"
        });

        final docRef = subjectCollection.doc(uid).collection("ayats");

        for (Map<String, dynamic> data in saveData) {
          batch.set(docRef.doc(), data);
          print("Document created with ID: ${docRef.id}");
        }

        await batch.commit();

        print("Batch operation completed successfully");
      } else {
        print("saveData is empty. No documents to create.");
      }
    } catch (e) {
      print("Error during batch operation: $e");
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.isUpdate) {
  //     if (widget.subject != null) {
  //       subjectController.text = widget.subject!;
  //     }
  //     ayatParaControllers.clear();
  //     if (widget.ayats != null) {
  //       for (var ayatMap in widget.ayats!) {
  //         String ayatText = ayatMap['text'] ?? ''; // Ensure correct key is used
  //         ayatParaControllers.add(TextEditingController(text: ayatText));
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              AppTextField(
                controller: subjectController,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
                minLines: 1,
                decoration: inputDecoration(labelText: 'Subject'),
                validator: (s) {
                  if (s!.isEmpty) {
                    return 'Please enter subject.';
                  }
                  return null;
                },
              ),
              16.height,
              for (int i = 0; i < saveData.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${saveData[i]['surahName']}"),
                    Text("${saveData[i]['arabic']}"),
                    10.height,
                  ],
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: AppButton(
                  color: colorPrimary,
                  onTap: () {
                    setState(() {
                      ayatParaControllers.add(TextEditingController());
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
              16.height,
              // ListView.builder(
              //   shrinkWrap: true,
              //   itemCount: ayatParaControllers.length,
              //   itemBuilder: (context, index) {
              //     return Row(
              //       children: [
              //         Expanded(
              //           child: Padding(
              //             padding: const EdgeInsets.all(8.0),
              //             child: AppTextField(
              //               controller: ayatParaControllers[index],
              //               textFieldType: TextFieldType.NUMBER,
              //               textCapitalization: TextCapitalization.sentences,
              //               maxLines: 1,
              //               minLines: 1,
              //               decoration: inputDecoration(
              //                   labelText:
              //                       'Type Surah No & Ayat No like this (1.2) '),
              //               validator: (s) {
              //                 return null;
              //               },
              //             ),
              //           ),
              //         ),
              //         if (index > 0)
              //           IconButton(
              //             icon: Icon(Icons.clear),
              //             onPressed: () {
              //               setState(() {
              //                 ayatParaControllers.removeAt(index);
              //                 // ayatParaList.removeAt(index);
              //                 // saveData.removeAt(index);
              //               });
              //             },
              //           ),
              //       ],
              //     );
              //   },
              // ),
              for (int index = 0; index < ayatParaControllers.length; index++)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AppTextField(
                          controller: ayatParaControllers[index],
                          textFieldType: TextFieldType.NUMBER,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 1,
                          minLines: 1,
                          decoration: inputDecoration(
                              labelText:
                                  'Type Surah No & Ayat No like this (1.2) '),
                          validator: (s) {
                            if (s!.isEmpty) {
                              return 'Please enter ayat no.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    if (index > 0)
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            if (ayatParaControllers.isNotEmpty) {
                              ayatParaControllers.removeAt(index);
                            }
                            if (ayatParaList.isNotEmpty) {
                              ayatParaList.removeAt(index);
                            }
                            if (saveData.isNotEmpty) {
                              saveData.removeAt(index);
                            }
                          });
                        },
                      ),
                  ],
                ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    padding: EdgeInsets.all(16),
                    child: Text(isUpdate ? 'Save' : 'Create Now',
                        style: primaryTextStyle(color: white)),
                    color: colorPrimary,
                    onTap: () {
                      isSave = true;
                      setState(() {});
                      for (int i = 0; i < ayatParaControllers.length; i++) {
                        ayatParaList.add(ayatParaControllers[i].text);
                        print('object${ayatParaList[i]}');
                      }
                      fetchData();
                      toast("Subject Created Successfully");
                      AdminDashboardScreen().launch(context, isNewTask: true);
                      // SubjectDetailScreen().launch(context, isNewTask: true);
                    },
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  AppButton(
                    padding: EdgeInsets.all(16),
                    child: Text('Find Surah & Ayat',
                        style: primaryTextStyle(color: white)),
                    color: colorPrimary,
                    onTap: () {
                      ayatParaList.clear();
                      for (int i = 0; i < ayatParaControllers.length; i++) {
                        ayatParaList.add(ayatParaControllers[i].text);
                        print('object${ayatParaControllers[i].text}');
                      }
                      fetchData();
                      toast("Surah Name & Ayat Finded");
                      // SubjectDetailScreen().launch(context, isNewTask: true);
                    },
                  )
                ],
              )
            ],
          ).paddingAll(16),
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
