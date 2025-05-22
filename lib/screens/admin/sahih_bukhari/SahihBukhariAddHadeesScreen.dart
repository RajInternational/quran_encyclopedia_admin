import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/HadeesData.dart';
import 'package:quizeapp/models/KitabData.dart';
import 'package:quizeapp/screens/admin/sahih_bukhari/SahihBukhariHadeesListWidget.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

class SahihBukhariAddHadeesScreen extends StatefulWidget {
  final HadeesData? data;

  SahihBukhariAddHadeesScreen({this.data});

  @override
  AddQuestionsScreenState createState() => AddQuestionsScreenState();
}

class AddQuestionsScreenState extends State<SahihBukhariAddHadeesScreen> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer categoryMemoizer = AsyncMemoizer<List<CategoryData>>();

  // SubCategoryServices subCategoryServices;

  String questionType = QuestionTypeOption;

  String? correctAnswer;

  int? questionTypeGroupValue = 1;
  CategoryData? selectedCategory;
  // CategoryData selectedSubCategory;

  List<CategoryData> categories = [];

  bool isUpdate = false;

  TextEditingController sNoCont = TextEditingController();
  TextEditingController hadithNoCont = TextEditingController();
  TextEditingController kitabIdCont = TextEditingController();
  TextEditingController kitabCont = TextEditingController();
  TextEditingController baabIdCont = TextEditingController();
  TextEditingController baabCont = TextEditingController();
  TextEditingController bookInEnglishCont = TextEditingController();
  TextEditingController bookInUrduCont = TextEditingController();
  TextEditingController bookInArabicCont = TextEditingController();
  TextEditingController arabicCont = TextEditingController();
  TextEditingController urduCont = TextEditingController();
  TextEditingController englishCont = TextEditingController();
  TextEditingController volumeCont = TextEditingController();
  TextEditingController raviCont = TextEditingController();
  TextEditingController englishLinkCont = TextEditingController();
  TextEditingController urduLinkCont = TextEditingController();

  KitabData? selectedKitab;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.data != null;

    if (isUpdate) {
      sNoCont.text = widget.data!.sNo.toString().validate();
      hadithNoCont.text = widget.data!.hadithNo.toString().validate();
      kitabCont.text = widget.data!.kitab.validate();
      kitabIdCont.text = widget.data!.kitabId.validate();
      baabIdCont.text = widget.data!.baabId.validate();
      baabCont.text = widget.data!.baab.validate();
      bookInArabicCont.text = widget.data!.bookInArabic.validate();
      bookInEnglishCont.text = widget.data!.bookInEnglish.validate();
      bookInUrduCont.text = widget.data!.bookInUrdu.validate();
      arabicCont.text = widget.data!.arabic.validate();
      urduCont.text = widget.data!.urdu.validate();
      englishCont.text = widget.data!.english.validate();
      volumeCont.text = widget.data!.volume.validate();
      raviCont.text = widget.data!.ravi.validate();
      englishLinkCont.text = widget.data!.youtubeEnglishLink.validate();
      urduLinkCont.text = widget.data!.youtubeUrduLink.validate();

      var kitabs = sahihBukhariKitabList
          .where((element) =>
              element.bookId.toString() == widget.data!.kitabId! &&
              element.name == widget.data!.kitab!)
          .toList();
      if (kitabs.isNotEmpty) {
        selectedKitab = kitabs.first;
      }
    }

    bookInUrduCont = TextEditingController(text: 'صحیح بخاری شریف');
    bookInEnglishCont = TextEditingController(text: 'Sahih Bukhari');

    // /// Load categories
    // categories = await categoryService.categoriesFuture();
    //
    // if (categories.isNotEmpty) {
    //   if (isUpdate) {
    //     try {
    //       selectedCategory = categories.firstWhere((element) => element.id == widget.data!.categoryRef!.id);
    //     } catch (e) {
    //       print(e);
    //     }
    //   } else {
    //     selectedCategory = categories.first;
    //   }
    // }

    setState(() {});
  }

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      if (selectedKitab != null) {
        HadeesData hadeesData = HadeesData();

        hadeesData.sNo = hadithNoCont.text.trim().toInt();
        ;
        hadeesData.hadithNo = hadithNoCont.text.trim().toInt();
        hadeesData.kitabId = kitabIdCont.text.trim();
        hadeesData.kitab = kitabCont.text.trim();
        hadeesData.baabId = baabIdCont.text.trim();
        hadeesData.baab = baabCont.text.trim();
        hadeesData.bookInEnglish = bookInEnglishCont.text.trim();
        hadeesData.bookInArabic = bookInArabicCont.text.trim();
        hadeesData.bookInUrdu = bookInUrduCont.text.trim();
        hadeesData.arabic = arabicCont.text.trim();
        hadeesData.english = englishCont.text.trim();
        hadeesData.urdu = urduCont.text.trim();
        hadeesData.volume = volumeCont.text.trim();
        hadeesData..ravi = raviCont.text.trim();
        hadeesData.youtubeEnglishLink = englishLinkCont.text.trim();
        hadeesData.youtubeUrduLink = urduLinkCont.text.trim();
        hadeesData.updatedAt = DateTime.now();

        if (isUpdate) {
          // hadeesData.id = widget.data!.id;
          hadeesData.createdAt = widget.data!.createdAt;

          await sahihBukhariHadeesService
              .updateDocument(hadeesData.toJson(), hadeesData.sNo.toString())
              .then((value) {
            toast('Update Successfully',
                length: Toast.LENGTH_LONG,
                bgColor: Colors.green,
                textColor: Colors.white);
            finish(context);
          }).catchError((e) {
            toast(e.toString());
          });
        } else {
          hadeesData.createdAt = DateTime.now();

          sahihBukhariHadeesService
              .addDocumentWithCustomId(
                  hadeesData.sNo.toString(), hadeesData.toJson())
              .then((value) {
            toast('Add Question Successfully',
                length: Toast.LENGTH_LONG,
                bgColor: Colors.green,
                textColor: Colors.white);

            sNoCont.clear();
            hadithNoCont.clear();
            kitabCont.clear();
            kitabIdCont.clear();
            baabIdCont.clear();
            baabCont.clear();
            bookInArabicCont.clear();
            // bookInEnglishCont.clear();
            // bookInUrduCont.clear();
            arabicCont.clear();
            urduCont.clear();
            englishCont.clear();
            volumeCont.clear();
            raviCont.clear();
            englishLinkCont.clear();
            urduLinkCont.clear();

            setState(() {});
          }).catchError((e) {
            log(e);
          });
        }
      }
    }
  }

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text('Do you want to delete this question?'),
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

                sahihBukhariHadeesService
                    .removeDocument(widget.data!.sNo.toString())
                    .then((value) {
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0.0,
        leading: isUpdate
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: black,
                ),
                onPressed: () {
                  finish(context);
                },
              )
            : null,
        title: Row(
          children: [
            Text(
              'Sahih Bukhari Hadees',
              style: boldTextStyle(),
            ),
            8.width,
            Text(
              !isUpdate
                  ? 'Create New Sahih Bukhari Hadees'
                  : 'Update Sahih Bukhari Hadees',
              style: secondaryTextStyle(),
            ),
          ],
        ),
        actions: [
          isUpdate
              ? IconButton(
                  icon: Icon(Icons.delete_forever, color: black),
                  onPressed: () {
                    _showDeleteDialog();
                  },
                ).paddingOnly(right: 8)
              : SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              // AppTextField(
              //   controller: sNoCont,
              //   textFieldType: TextFieldType.NAME,
              //   textCapitalization: TextCapitalization.sentences,
              //   maxLines: 1,
              //   // height: 200,
              //   minLines: 1,
              //   decoration: inputDecoration(labelText: 'S No'),
              //   validator: (s) {
              //     // if (s!.trim().isEmpty) return errorThisFieldRequired;
              //     return null;
              //   },
              // ),
              // 16.height,
              AppTextField(
                controller: hadithNoCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(labelText: 'Hadith No'),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),
              16.height,

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: gray.withOpacity(0.5),
                    width: 0.3,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<KitabData>(
                    isExpanded: true,
                    value: selectedKitab,
                    hint: Text('Select Kitab'),
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black),

                    // underline: Container(
                    //   height: 2,
                    //   color: Colors.deepPurpleAccent,
                    // ),
                    onChanged: (KitabData? newValue) {
                      setState(() {
                        selectedKitab = newValue;
                        kitabIdCont.text = selectedKitab!.bookId.toString();
                        kitabCont.text = selectedKitab!.name!;
                      });
                    },
                    items: sahihBukhariKitabList
                        .map<DropdownMenuItem<KitabData>>((KitabData value) {
                      return DropdownMenuItem<KitabData>(
                        value: value,
                        child: Text(value.name!),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // AppTextField(
              //   controller: kitabIdCont,
              //   textFieldType: TextFieldType.NAME,
              //   textCapitalization: TextCapitalization.sentences,
              //   maxLines: 1,
              //   // height: 200,
              //   minLines: 1,
              //   decoration: inputDecoration(labelText: 'Kitab ID'),
              //   validator: (s) {
              //     // if (s!.trim().isEmpty) return errorThisFieldRequired;
              //     return null;
              //   },
              // ),
              // 16.height,
              // AppTextField(
              //   controller: kitabCont,
              //   textFieldType: TextFieldType.NAME,
              //   textCapitalization: TextCapitalization.sentences,
              //   maxLines: 1,
              //   // height: 200,
              //   minLines: 1,
              //   decoration: inputDecoration(labelText: 'Kitab'),
              //   validator: (s) {
              //     // if (s!.trim().isEmpty) return errorThisFieldRequired;
              //     return null;
              //   },
              // ),
              16.height,
              // AppTextField(
              //   controller: baabIdCont,
              //   textFieldType: TextFieldType.NAME,
              //   textCapitalization: TextCapitalization.sentences,
              //   maxLines: 1,
              //   // height: 200,
              //   minLines: 1,
              //   decoration: inputDecoration(labelText: 'Baab ID'),
              //   validator: (s) {
              //     // if (s!.trim().isEmpty) return errorThisFieldRequired;
              //     return null;
              //   },
              // ),
              // 16.height,
              AppTextField(
                controller: baabCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(labelText: 'Baab'),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),

              16.height,
              // AppTextField(
              //   controller: bookInArabicCont,
              //   textFieldType: TextFieldType.NAME,
              //   textCapitalization: TextCapitalization.sentences,
              //   maxLines: 1,
              //   // height: 200,
              //   minLines: 1,
              //   decoration: inputDecoration(labelText: 'Book In Arabic'),
              //   validator: (s) {
              //     // if (s!.trim().isEmpty) return errorThisFieldRequired;
              //     return null;
              //   },
              // ),
              // 16.height,
              // AppTextField(
              //   controller: bookInEnglishCont,
              //   textFieldType: TextFieldType.NAME,
              //   textCapitalization: TextCapitalization.sentences,
              //   maxLines: 1,
              //   // height: 200,
              //   minLines: 1,
              //   decoration: inputDecoration(labelText: 'Book In English'),
              //   validator: (s) {
              //     // if (s!.trim().isEmpty) return errorThisFieldRequired;
              //     return null;
              //   },
              // ),
              // 16.height,
              AppTextField(
                controller: bookInUrduCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 100,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(labelText: 'Book In Urdu'),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),
              16.height,

              AppTextField(
                textStyle: GoogleFonts.notoNastaliqUrdu(),
                controller: arabicCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 500,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(labelText: 'Arabic'),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),
              16.height,
              AppTextField(
                textStyle: GoogleFonts.notoNastaliqUrdu(),
                controller: urduCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 500,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(labelText: 'Urdu'),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: englishCont,
                textFieldType: TextFieldType.MULTILINE,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 500,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(labelText: 'English'),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),

              16.height,
              // AppTextField(
              //   controller: volumeCont,
              //   textFieldType: TextFieldType.NAME,
              //   textCapitalization: TextCapitalization.sentences,
              //   maxLines: 1,
              //   // height: 200,
              //   minLines: 1,
              //   decoration: inputDecoration(labelText: 'Volume'),
              //   validator: (s) {
              //     // if (s!.trim().isEmpty) return errorThisFieldRequired;
              //     return null;
              //   },
              // ),
              //
              // 16.height,
              AppTextField(
                controller: raviCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(
                  labelText: 'Ravi',
                ),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),

              16.height,
              AppTextField(
                controller: englishLinkCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(
                  labelText: 'English Youtube Link',
                ),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),

              16.height,
              AppTextField(
                controller: urduLinkCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
                // height: 200,
                minLines: 1,
                decoration: inputDecoration(
                  labelText: 'Urdu Youtube Link',
                ),
                validator: (s) {
                  // if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),

              16.height,
              AppButton(
                padding: EdgeInsets.all(16),
                child: Text(isUpdate ? 'Save' : 'Create Now',
                    style: primaryTextStyle(color: white)),
                color: colorPrimary,
                onTap: () {
                  save();
                },
              )
            ],
          ).paddingAll(16),
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
