import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/HadeesData.dart';
import 'package:quizeapp/models/KitabData.dart';

import '../../../utils/Colors.dart';
import '../../../utils/ModelKeys.dart';
import 'SahihBukhariAddHadeesScreen.dart';
import 'SahihBukhariHadeesDetailScreen.dart';

List<KitabData> sahihBukhariKitabList = [];

class SahihBukhariHadeesListWidget extends StatefulWidget {
  final HadeesData? quizData;

  SahihBukhariHadeesListWidget({this.quizData});

  @override
  SahihBukhariHadeesListWidgetState createState() =>
      SahihBukhariHadeesListWidgetState();
}

class SahihBukhariHadeesListWidgetState
    extends State<SahihBukhariHadeesListWidget> {
  List<CategoryData> categories = [];
  List<CategoryData> categoriesFilter = [];
  List<HadeesData> questionList = [];
  List<HadeesData> listOfHadees = [];
  CategoryData? selectedCategoryForFilter;
  bool isLoading = true;
  bool isUpdate = false;
  String hadeesCount = '';
  late CategoryData selectedCategory;
  QuerySnapshot? _snapshot;
  int startPage = 1;
  int selectedPage = 1;
  int totalHadeesCount = 7620;
  DocumentSnapshot? _lastDocument;
  final int _perPage = 15;
  bool loading = false;
  int currentPage = 1;
  TextEditingController _pageController = TextEditingController();

  ScrollController controller = ScrollController(initialScrollOffset: 0);
  Future<void> _loadData() async {
    setState(() => loading = true);
    // COMMENTED: Hadith books Firebase fetching disabled - not in use
    // try {
    //   final startAtValue = ((selectedPage - 1) * _perPage) + 1;
    //   final endBeforeValue = (selectedPage * _perPage) + 1;
    //   QuerySnapshot snapshot;
    //   if (selectedCategoryForFilter != null && selectedCategoryForFilter!.id != null) {
    //     snapshot = await FirebaseFirestore.instance
    //         .collection('Books').doc('HadithBooks').collection('CompleteBukhari')
    //         .where('category', isEqualTo: categoryService.ref!.doc(selectedCategoryForFilter!.id)!)
    //         .orderBy(CommonKeys.hadithNo).startAt([startAtValue]).endBefore([endBeforeValue]).limit(_perPage).get();
    //   } else {
    //     snapshot = await FirebaseFirestore.instance
    //         .collection('Books').doc('HadithBooks').collection('CompleteBukhari')
    //         .orderBy(CommonKeys.hadithNo).startAt([startAtValue]).endBefore([endBeforeValue]).limit(_perPage).get();
    //   }
    //   listOfHadees.clear();
    //   if (snapshot.docs.isNotEmpty) {
    //     final tempHadeesList = snapshot.docs.map((e) => HadeesData.fromJson(e.data() as Map<String, dynamic>)).toList();
    //     for (int i = 0; i < tempHadeesList.length; i++) { listOfHadees.add(tempHadeesList[i]); }
    //     _lastDocument = snapshot.docs.last;
    //   } else { _lastDocument = null; }
    // } catch (e) { log('Did not load hadees => $e'); }
    listOfHadees.clear();
    _lastDocument = null;
    setState(() => loading = false);
  }
  // Future<void> _loadData() async {
  //   QuerySnapshot snapshot;
  //   if (selectedCategoryForFilter != null &&
  //       selectedCategoryForFilter!.id != null) {
  //     snapshot = await FirebaseFirestore.instance
  //         .collection('Books')
  //         .doc('HadithBooks')
  //         .collection('CompleteBukhari')
  //         .where('category',
  //             isEqualTo:
  //                 categoryService.ref!.doc(selectedCategoryForFilter!.id)!)
  //         .orderBy(CommonKeys.hadithNo)
  //         .limit(_perPage)
  //         .get();
  //   } else {
  //     snapshot = await FirebaseFirestore.instance
  //         .collection('Books')
  //         .doc('HadithBooks')
  //         .collection('CompleteBukhari')
  //         .orderBy(CommonKeys.hadithNo)
  //         .limit(_perPage)
  //         .get();
  //
  //     print('snapshot ${snapshot.docs.length}');
  //   }
  //
  //   setState(() {
  //     _snapshot = snapshot;
  //
  //     listOfHadees.addAll(_snapshot!.docs
  //         .map((e) => HadeesData.fromJson(e.data() as Map<String, dynamic>)));
  //     if (snapshot.docs.isNotEmpty) {
  //       _lastDocument = snapshot.docs.last;
  //     }
  //   });
  // }

  Future<void> _loadMoreData() async {
    // COMMENTED: Hadith books Firebase fetching disabled - not in use
    // if (_lastDocument == null) return;
    // QuerySnapshot snapshot;
    // if (selectedCategoryForFilter != null && selectedCategoryForFilter!.id != null) {
    //   snapshot = await FirebaseFirestore.instance
    //       .collection('Books').doc('HadithBooks').collection('CompleteBukhari')
    //       .where('category', isEqualTo: categoryService.ref!.doc(selectedCategoryForFilter!.id)!)
    //       .orderBy(CommonKeys.hadithNo).startAfterDocument(_lastDocument!).limit(_perPage).get();
    // } else {
    //   snapshot = await FirebaseFirestore.instance
    //       .collection('Books').doc('HadithBooks').collection('CompleteBukhari')
    //       .orderBy(CommonKeys.hadithNo).startAfterDocument(_lastDocument!).limit(_perPage).get();
    // }
    // setState(() {
    //   if (snapshot.docs.isNotEmpty && _snapshot != null) {
    //     _snapshot!.docs.addAll(snapshot.docs);
    //     final tempHadeesList = snapshot.docs.map((e) => HadeesData.fromJson(e.data() as Map<String, dynamic>)).toList();
    //     for (int i = 0; i < tempHadeesList.length; i++) { listOfHadees.add(tempHadeesList[i]); }
    //     _lastDocument = snapshot.docs.last;
    //   } else { _lastDocument = null; }
    //   }
    // });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // loadQuestion();
    // await sahihBukhariKitabService.kitabsFuture().then((value) {
    //   sahihBukhariKitabList = value;
    //   setState(() {});
    // }).catchError((e) {
    //   debugPrint(e.toString());
    // });
    _loadData();
    // categoryService.categoriesFuture().then((value) async {
    //   categoriesFilter.add(CategoryData(name: 'All Question Papers'));
    //   value.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    //   categories.addAll(value);
    //   categoriesFilter.addAll(value);
    //
    //   selectedCategoryForFilter = categoriesFilter.first;
    //
    //   setState(() {});
    //
    //   /// Load categories
    //   categories = await categoryService.categoriesFuture();
    //
    //   if (categories.isNotEmpty) {
    //     if (isUpdate) {
    //       try {
    //         selectedCategory = await categoryService
    //             .getCategoryById(widget.quizData!.categoryId);
    //
    //         log(selectedCategory.name);
    //       } catch (e) {
    //         print(e);
    //       }
    //     } else {
    //       selectedCategory = categories.first;
    //     }
    //   }
    //
    //   setState(() {});
    // }).catchError((e) {
    //
    // });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> loadQuestion({DocumentReference? categoryRef}) async {
    isLoading = true;
    // sahihBukhariHadeesService.questionListFuture(categoryRef: categoryRef).then((value) {
    //   isLoading = false;
    //   questionList.clear();
    //   // value.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    //   questionList.addAll(value);
    //
    //   setState(() {});
    // }).catchError((e) {
    //   isLoading = false;
    //   setState(() {});
    //   toast(e.toString());
    // });

    // sahihBukhariHadeesService.countHadees().then((value) {
    //   isLoading = false;
    //   hadeesCount = value.toString();
    //   setState(() {});
    // }).catchError((e) {
    //   isLoading = false;
    //   setState(() {});
    //   toast(e.toString());
    // });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Container(
          height: 150,
          child: Row(
            children: [
              Text('Sahih Bukhari All Hadees', style: boldTextStyle()),
              16.width,
              Row(
                children: [
                  // if (categories.isNotEmpty || isLoading)
                  //   Container(
                  //     padding: EdgeInsets.only(left: 8, right: 8),
                  //     decoration: BoxDecoration(
                  //         borderRadius: radius(), color: Colors.grey.shade200),
                  //     child: DropdownButton(
                  //       underline: Offstage(),
                  //       hint: Text('Please choose a question paper'),
                  //       items: categoriesFilter.map((e) {
                  //         return DropdownMenuItem(
                  //             child: Text(e.name.validate()), value: e);
                  //       }).toList(),
                  //       // isExpanded: true,
                  //       value: selectedCategoryForFilter,
                  //       onChanged: (dynamic c) {
                  //         selectedCategoryForFilter = c;
                  //
                  //         setState(() {});
                  //
                  //         if (selectedCategoryForFilter!.id == null) {
                  //           loadQuestion();
                  //         } else {
                  //           loadQuestion(
                  //               categoryRef: categoryService.ref!
                  //                   .doc(selectedCategoryForFilter!.id));
                  //         }
                  //       },
                  //     ),
                  //   ),
                  // 16.width,
                  // AppButton(
                  //   padding: EdgeInsets.all(16),
                  //   color: colorPrimary,
                  //   child: Text('Clear', style: primaryTextStyle(color: white)),
                  //   onTap: () {
                  //     selectedCategoryForFilter = categoriesFilter.first;
                  //     // selectedQuestionList.clear();
                  //     loadQuestion();
                  //   },
                  // ),
                  16.width,
                  isLoading
                      ? SizedBox()
                      : hadeesCount.isNotEmpty
                          ? Text("Hadees Count: " + hadeesCount,
                              style: boldTextStyle())
                          : SizedBox(),
                  16.width,
                ],
              ),
            ],
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child:
            // Scrollbar(
            //     key: Key("scroll-bar"),
            //     thickness: 5.0,
            //     controller: controller,
            //     radius: Radius.circular(16),
            //     child:
            // FirestoreListView(
            //   shrinkWrap: true,
            //   query: selectedCategoryForFilter != null &&
            //       selectedCategoryForFilter!.id != null
            //       ? sahihBukhariHadeesService.getQuestionsList(
            //       categoryRef:
            //       categoryService.ref!.doc(selectedCategoryForFilter!.id))!
            //       : sahihBukhariHadeesService.getQuestionsList()!,
            //   pageSize: DocLimit,
            //   emptyBuilder: (context) => noDataWidget(),
            //   errorBuilder: (context, error, stackTrace) =>
            //       Text(error.toString(), style: primaryTextStyle()).center(),
            //   loadingBuilder: (context) => Loader(),
            //   itemBuilder: (context, doc, index) {
            //     HadeesData data =
            //     HadeesData.fromJson(doc.data() as Map<String, dynamic>);
            //
            //     return Container(
            //       decoration: BoxDecoration(
            //           boxShadow: defaultBoxShadow(),
            //           color: Colors.white,
            //           borderRadius: radius()),
            //       margin: EdgeInsets.only(bottom: 16, top: 16, right: 4),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Row(
            //             children: [
            //               Container(
            //                 padding: EdgeInsets.all(16),
            //                 margin: EdgeInsets.only(top: 8, bottom: 8),
            //                 decoration: boxDecorationWithRoundedCorners(
            //                     border: Border.all(
            //                         color: gray.withOpacity(0.4), width: 0.1)),
            //                 child: Text('${index}. ${data.hadithNo}',
            //                     style:
            //                     boldTextStyle(color: colorPrimary, size: 18)),
            //               ).expand(),
            //               16.width,
            //               IconButton(
            //                 icon: Icon(Icons.delete_forever, color: black),
            //                 onPressed: () {
            //                   _showDeleteDialog(data.sNo.toString());
            //                 },
            //               ).paddingOnly(right: 8),
            //               IconButton(
            //                 icon: Icon(Icons.open_in_new, color: black),
            //                 onPressed: () {
            //                   SahihBukhariHadeesDetailScreen(data: data)
            //                       .launch(context);
            //                 },
            //               ),
            //               IconButton(
            //                 icon: Icon(Icons.edit, color: black),
            //                 onPressed: () {
            //                   SahihBukhariAddHadeesScreen(data: data)
            //                       .launch(context);
            //                 },
            //               ),
            //             ],
            //           ),
            //           16.height,
            //           Row(
            //             children: [
            //               Text('Baab :', style: boldTextStyle(size: 18)),
            //               8.width,
            //               Container(
            //                 alignment: Alignment.center,
            //                 padding: EdgeInsets.all(8),
            //                 decoration: boxDecorationWithRoundedCorners(
            //                   borderRadius: BorderRadius.circular(8),
            //                   border: Border.all(
            //                       color: gray.withOpacity(0.4), width: 0.1),
            //                 ),
            //                 child: Text(data.baab ?? '', style: boldTextStyle()),
            //               ),
            //             ],
            //           ),
            //           16.height,
            //           Row(
            //             children: [
            //               Text('Kitab:', style: boldTextStyle(size: 18)),
            //               8.width,
            //               Container(
            //                 alignment: Alignment.center,
            //                 padding: EdgeInsets.all(8),
            //                 decoration: boxDecorationWithRoundedCorners(
            //                   borderRadius: BorderRadius.circular(8),
            //                   border: Border.all(
            //                       color: gray.withOpacity(0.4), width: 0.1),
            //                 ),
            //                 child: Text(data.kitab ?? '', style: boldTextStyle()),
            //               ),
            //             ],
            //           ),
            //           16.height,
            //           // Row(
            //           //   children: [
            //           //     Text('Book In Arabic:', style: boldTextStyle(size: 18)),
            //           //     8.width,
            //           //     Container(
            //           //       alignment: Alignment.center,
            //           //       padding: EdgeInsets.all(8),
            //           //       decoration: boxDecorationWithRoundedCorners(
            //           //         borderRadius: BorderRadius.circular(8),
            //           //         border: Border.all(
            //           //             color: gray.withOpacity(0.4), width: 0.1),
            //           //       ),
            //           //       child:
            //           //       Text(data.bookInArabic??'', style: boldTextStyle()),
            //           //     ),
            //           //   ],
            //           // ),
            //           // 16.height,
            //           // Row(
            //           //   children: [
            //           //     Text('Book In English:', style: boldTextStyle(size: 18)),
            //           //     8.width,
            //           //     Container(
            //           //       alignment: Alignment.center,
            //           //       padding: EdgeInsets.all(8),
            //           //       decoration: boxDecorationWithRoundedCorners(
            //           //         borderRadius: BorderRadius.circular(8),
            //           //         border: Border.all(
            //           //             color: gray.withOpacity(0.4), width: 0.1),
            //           //       ),
            //           //       child:
            //           //       Text(data.bookInEnglish??'', style: boldTextStyle()),
            //           //     ),
            //           //   ],
            //           // ),
            //           // 16.height,
            //           Row(
            //             children: [
            //               Text('Book In Urdu:', style: boldTextStyle(size: 18)),
            //               8.width,
            //               Container(
            //                 alignment: Alignment.center,
            //                 padding: EdgeInsets.all(8),
            //                 decoration: boxDecorationWithRoundedCorners(
            //                   borderRadius: BorderRadius.circular(8),
            //                   border: Border.all(
            //                       color: gray.withOpacity(0.4), width: 0.1),
            //                 ),
            //                 child:
            //                 Text(data.bookInUrdu ?? '', style: boldTextStyle()),
            //               ),
            //             ],
            //           )
            //         ],
            //       ).paddingSymmetric(horizontal: 16, vertical: 16),
            //     );
            //   },
            // ),
            loading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      listOfHadees.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: listOfHadees.length,
                                itemBuilder: (context, index) {
                                  HadeesData data;
                                  if (listOfHadees.length > 5) {
                                    data = listOfHadees[index];
                                  } else {
                                    data = HadeesData.fromJson(
                                        _snapshot!.docs[index].data()
                                            as Map<String, dynamic>);
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                        boxShadow: defaultBoxShadow(),
                                        color: Colors.white,
                                        borderRadius: radius()),
                                    margin: EdgeInsets.only(
                                        bottom: 16, top: 16, right: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              margin: EdgeInsets.only(
                                                  top: 8, bottom: 8),
                                              decoration:
                                                  boxDecorationWithRoundedCorners(
                                                      border: Border.all(
                                                          color: gray
                                                              .withOpacity(0.4),
                                                          width: 0.1)),
                                              child: Text(
                                                  '${index}. ${data.hadithNo}',
                                                  style: boldTextStyle(
                                                      color: colorPrimary,
                                                      size: 18)),
                                            ).expand(),
                                            16.width,
                                            IconButton(
                                              icon: Icon(Icons.delete_forever,
                                                  color: black),
                                              onPressed: () {
                                                _showDeleteDialog(
                                                    data.sNo.toString());
                                              },
                                            ).paddingOnly(right: 8),
                                            IconButton(
                                              icon: Icon(Icons.open_in_new,
                                                  color: black),
                                              onPressed: () {
                                                SahihBukhariHadeesDetailScreen(
                                                        data: data)
                                                    .launch(context);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: black),
                                              onPressed: () {
                                                SahihBukhariAddHadeesScreen(
                                                        data: data)
                                                    .launch(context);
                                              },
                                            ),
                                          ],
                                        ),
                                        16.height,
                                        Row(
                                          children: [
                                            Text('Baab :',
                                                style: boldTextStyle(size: 18)),
                                            8.width,
                                            Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(8),
                                              decoration:
                                                  boxDecorationWithRoundedCorners(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        gray.withOpacity(0.4),
                                                    width: 0.1),
                                              ),
                                              child: Text(data.baab ?? '',
                                                  style: boldTextStyle()),
                                            ),
                                          ],
                                        ),
                                        16.height,
                                        Row(
                                          children: [
                                            Text('Kitab:',
                                                style: boldTextStyle(size: 18)),
                                            8.width,
                                            Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(8),
                                              decoration:
                                                  boxDecorationWithRoundedCorners(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        gray.withOpacity(0.4),
                                                    width: 0.1),
                                              ),
                                              child: Text(data.kitab ?? '',
                                                  style: boldTextStyle()),
                                            ),
                                          ],
                                        ),
                                        16.height,
                                        // Row(
                                        //   children: [
                                        //     Text('Book In Arabic:', style: boldTextStyle(size: 18)),
                                        //     8.width,
                                        //     Container(
                                        //       alignment: Alignment.center,
                                        //       padding: EdgeInsets.all(8),
                                        //       decoration: boxDecorationWithRoundedCorners(
                                        //         borderRadius: BorderRadius.circular(8),
                                        //         border: Border.all(
                                        //             color: gray.withOpacity(0.4), width: 0.1),
                                        //       ),
                                        //       child:
                                        //       Text(data.bookInArabic??'', style: boldTextStyle()),
                                        //     ),
                                        //   ],
                                        // ),
                                        // 16.height,
                                        // Row(
                                        //   children: [
                                        //     Text('Book In English:', style: boldTextStyle(size: 18)),
                                        //     8.width,
                                        //     Container(
                                        //       alignment: Alignment.center,
                                        //       padding: EdgeInsets.all(8),
                                        //       decoration: boxDecorationWithRoundedCorners(
                                        //         borderRadius: BorderRadius.circular(8),
                                        //         border: Border.all(
                                        //             color: gray.withOpacity(0.4), width: 0.1),
                                        //       ),
                                        //       child:
                                        //       Text(data.bookInEnglish??'', style: boldTextStyle()),
                                        //     ),
                                        //   ],
                                        // ),
                                        // 16.height,
                                        Row(
                                          children: [
                                            Text('Book In Urdu:',
                                                style: boldTextStyle(size: 18)),
                                            8.width,
                                            Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(8),
                                              decoration:
                                                  boxDecorationWithRoundedCorners(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        gray.withOpacity(0.4),
                                                    width: 0.1),
                                              ),
                                              child: Text(data.bookInUrdu ?? '',
                                                  style: boldTextStyle()),
                                            ),
                                          ],
                                        )
                                      ],
                                    ).paddingSymmetric(
                                        horizontal: 16, vertical: 16),
                                  );
                                },
                              ),
                            )
                          : Center(child: Text('No Hadees Found')),
                      Container(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // First page arrow
                            // IconButton(
                            //   icon: Icon(Icons.skip_previous),
                            //   onPressed: () {
                            //     setState(() {
                            //       selectedPage = 1;
                            //       startPage = 1;
                            //     });
                            //   },
                            // ),
                            // Previous page arrow
                            // IconButton(
                            //   icon: Icon(
                            //     Icons.keyboard_double_arrow_left_outlined,
                            //     size: 20,
                            //   ),
                            //   onPressed: () {
                            //     if (startPage - 10 >= 1) {
                            //       setState(() {
                            //         startPage -= 10;
                            //       });
                            //     } else {
                            //       setState(() {
                            //         startPage = 1;
                            //       });
                            //     }
                            //   },
                            // ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                              ),
                              onPressed: () async {
                                if (selectedPage > 1) {
                                  selectedPage--;
                                  await _loadData();
                                }
                                setState(() {});
                              },
                            ),
                            // Page numbers
                            for (int i = currentPage; i <= currentPage + 9; i++)
                              if (i <= (totalHadeesCount / _perPage).ceil())
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      selectedPage = i;

                                      await _loadData();
                                      setState(() {});
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: i == selectedPage
                                          ? Colors.green
                                          : Colors.white,
                                      child: Text(
                                        '$i',
                                        style: TextStyle(
                                          color: i == selectedPage
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            // Next ten pages arrow
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                              onPressed: () {
                                if (currentPage + 10 <=
                                    (totalHadeesCount / _perPage).ceil()) {
                                  setState(() {
                                    currentPage += 10;
                                  });
                                }
                              },
                            ),
                            // Next ten pages arrow
                            // IconButton(
                            //   icon: Icon(
                            //     Icons.keyboard_double_arrow_right,
                            //     size: 20,
                            //   ),
                            //   onPressed: () {
                            //     if (startPage + 10 <=
                            //         (totalHadeesCount / _perPage).ceil()) {
                            //       setState(() {
                            //         startPage += 10;
                            //       });
                            //     } else {
                            //       setState(() {
                            //         startPage =
                            //             (totalHadeesCount / _perPage).ceil();
                            //       });
                            //     }
                            //   },
                            // ),
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
                                      String input =
                                          _pageController.text.trim();

                                      if (input.isNotEmpty) {
                                        int? pageNumber = int.tryParse(input);
                                        if (pageNumber != null &&
                                            pageNumber >= 1 &&
                                            pageNumber <=
                                                (totalHadeesCount / _perPage)
                                                    .ceil()) {
                                          setState(() {
                                            startPage = pageNumber;
                                            currentPage = pageNumber;
                                            selectedPage = pageNumber;
                                          });

                                          // Load data for the specified page
                                          await _loadData();
                                        }
                                      }
                                    },
                                    child: Text('Go'),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: colorPrimary,
                      //     foregroundColor: Colors.white,
                      //   ),
                      //   onPressed: _loadMoreData,
                      //   child: Text('Load More'),
                      // ),
                    ],
                  ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }

  // );

// String formatQuestion(String question) {
//   try {
//     var splitQuestion = question.split("?");
//     StringBuffer stringBuffer = StringBuffer();
//     stringBuffer.write(splitQuestion[0] + "?\n");
//     if (splitQuestion.length > 1 && splitQuestion[1].contains("1. ")) {
//       var splitOption1 = splitQuestion[1].split("2. ");
//       stringBuffer.write(splitOption1[0] + "\n");
//
//       var splitOption2 = splitOption1[1].split("3. ");
//       stringBuffer.write("2. " + splitOption2[0] + "\n");
//       var splitOption3 = splitOption2[1].split("4. ");
//       stringBuffer.write("3. " + splitOption3[0] + "\n");
//       var splitOption4 = splitOption3[1].split("5. ");
//
//       stringBuffer.write("4. " + splitOption4[0] + "\n");
//
//       if (splitOption4.length > 1) {
//         var splitOption5 = splitOption4[1].split("6. ");
//         stringBuffer.write("5. " + splitOption5[0] + "\n");
//         if (splitOption5.length > 1) {
//           stringBuffer.write("6. " + splitOption5[1]);
//         }
//       }
//     }
//
//     return stringBuffer.toString();
//   } catch (ex) {
//     return question;
//   }
// }

  Future<void> _showDeleteDialog(String docId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text('Do you want to delete this hadees?'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                finish(context);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                // if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

                sahihBukhariHadeesService.removeDocument(docId).then((value) {
                  toast('Delete Successfully');
                  finish(context);
                  finish(context);
                }).catchError((e) {
                  toast(e.toString());
                });
              },
            ),
          ],
        );
      },
    );
  }
}
