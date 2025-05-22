import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/HadeesData.dart';
import 'package:quizeapp/models/KitabData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/pagination/paginate_firestore.dart';
import 'package:quizeapp/screens/admin/sahih_muslim/SahihMuslimAddHadeesScreen.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Constants.dart';

class AllQuestionsListWidget extends StatefulWidget {
  final QuizData? quizData;

  AllQuestionsListWidget({this.quizData});

  @override
  AllQuestionsListWidgetState createState() => AllQuestionsListWidgetState();
}

class AllQuestionsListWidgetState extends State<AllQuestionsListWidget> {
  List<CategoryData> categories = [];
  List<CategoryData> categoriesFilter = [];
  List<HadeesData> questionList = [];

  CategoryData? selectedCategoryForFilter;
  bool isLoading = true;
  bool isUpdate = false;
  late CategoryData selectedCategory;

  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    loadQuestion();

    categoryService.categoriesFuture().then((value) async {
      categoriesFilter.add(CategoryData(name: 'All Categories'));

      categories.addAll(value);
      categoriesFilter.addAll(value);

      selectedCategoryForFilter = categoriesFilter.first;

      setState(() {});

      /// Load categories
      categories = await categoryService.categoriesFuture();

      if (categories.isNotEmpty) {
        if (isUpdate) {
          try {
            selectedCategory = await categoryService
                .getCategoryById(widget.quizData!.categoryId);

            log(selectedCategory.name);
          } catch (e) {
            print(e);
          }
        } else {
          selectedCategory = categories.first;
        }
      }

      setState(() {});
    }).catchError((e) {
      //
    });


  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> loadQuestion({DocumentReference? categoryRef}) async {
    sahihMuslimHadeesService.questionListFuture(categoryRef: categoryRef).then((value) {
      isLoading = false;
      questionList.clear();
      questionList.addAll(value);

      setState(() {});
    }).catchError((e) {
      isLoading = false;
      setState(() {});
      toast(e.toString());
    });
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
              Text('All Hadees', style: boldTextStyle()),
              16.width,
              Row(
                children: [
                  if (categories.isNotEmpty)
                    Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: radius(), color: Colors.grey.shade200),
                      child: DropdownButton(
                        underline: Offstage(),
                        hint: Text('Please choose a category'),
                        items: categoriesFilter.map((e) {
                          return DropdownMenuItem(
                              child: Text(e.name.validate()), value: e);
                        }).toList(),
                        // isExpanded: true,
                        value: selectedCategoryForFilter,
                        onChanged: (dynamic c) {
                          selectedCategoryForFilter = c;

                          setState(() {});

                          if (selectedCategoryForFilter!.id == null) {
                            loadQuestion();
                          } else {
                            loadQuestion(
                                categoryRef: categoryService.ref!
                                    .doc(selectedCategoryForFilter!.id));
                          }
                        },
                      ),
                    ),
                  16.width,
                  AppButton(
                    padding: EdgeInsets.all(16),
                    color: colorPrimary,
                    child: Text('Clear', style: primaryTextStyle(color: white)),
                    onTap: () {
                      selectedCategoryForFilter = categoriesFilter.first;
                      // selectedQuestionList.clear();
                      loadQuestion();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Scrollbar(
        thickness: 5.0,
        controller: controller,
        radius: Radius.circular(16),
        child: PaginateFirestore(
          itemBuilderType: PaginateBuilderType.listView,
          itemBuilder: (context, documentSnapshot, index) {
            try {
              HadeesData data =
              HadeesData.fromJson(documentSnapshot as Map<String, dynamic>);
            }catch(ex){
              print(ex.toString());
            }
            HadeesData data =
                HadeesData.fromJson(documentSnapshot as Map<String, dynamic>);

            return Container(
              decoration: BoxDecoration(
                  boxShadow: defaultBoxShadow(),
                  color: Colors.white,
                  borderRadius: radius()),
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
                                color: gray.withOpacity(0.4), width: 0.1)),
                        child: Text('${index + 1}. ${data.hadithNo}',
                            style:
                                boldTextStyle(color: colorPrimary, size: 18)),
                      ).expand(),
                      16.width,
                      IconButton(
                        icon: Icon(Icons.edit, color: black),
                        onPressed: () {
                          SahihMuslimAddHadeesScreen(data: data).launch(context);
                        },
                      )
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Text('Baab :', style: boldTextStyle(size: 18)),
                      8.width,
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: gray.withOpacity(0.4), width: 0.1),
                        ),
                        child:
                        Text(data.baab!, style: boldTextStyle()),
                      ),
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Text('Kitab:', style: boldTextStyle(size: 18)),
                      8.width,
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: gray.withOpacity(0.4), width: 0.1),
                        ),
                        child:
                            Text(data.kitab!, style: boldTextStyle()),
                      ),
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Text('Book In Arabic:', style: boldTextStyle(size: 18)),
                      8.width,
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: gray.withOpacity(0.4), width: 0.1),
                        ),
                        child:
                        Text(data.bookInArabic!, style: boldTextStyle()),
                      ),
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Text('Book In English:', style: boldTextStyle(size: 18)),
                      8.width,
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: gray.withOpacity(0.4), width: 0.1),
                        ),
                        child:
                        Text(data.bookInEnglish!, style: boldTextStyle()),
                      ),
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Text('Book In Urdu:', style: boldTextStyle(size: 18)),
                      8.width,
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: gray.withOpacity(0.4), width: 0.1),
                        ),
                        child:
                        Text(data.bookInUrdu!, style: boldTextStyle()),
                      ),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 16, vertical: 16),
            );
          },
          shrinkWrap: true,
          padding: EdgeInsets.all(8),
          query: sahihMuslimHadeesService.getQuestions()!,
          itemsPerPage: DocLimit,
          bottomLoader: Loader(),
          initialLoader: Loader(),
          onEmpty: noDataWidget(),
          onError: (e) =>
              Text(e.toString(), style: primaryTextStyle()).center(),
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
