import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/utils/Constants.dart';

class ViewAyat extends StatefulWidget {
  List<dynamic> ayats;

  ViewAyat({required this.ayats});

  @override
  AddQuestionsScreenState createState() => AddQuestionsScreenState();
}

class AddQuestionsScreenState extends State<ViewAyat> {
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
  bool showUrduPlayer = false;
  bool showEnglishPlayer = false;
  //
  // TextEditingController sNoCont = TextEditingController();
  // TextEditingController hadithNoCont = TextEditingController();
  // TextEditingController kitabIdCont = TextEditingController();
  // TextEditingController kitabCont = TextEditingController();
  // TextEditingController baabIdCont = TextEditingController();
  // TextEditingController baabCont = TextEditingController();
  // TextEditingController bookInEnglishCont = TextEditingController();
  // TextEditingController bookInUrduCont = TextEditingController();
  // TextEditingController bookInArabicCont = TextEditingController();
  // TextEditingController arabicCont = TextEditingController();
  // TextEditingController urduCont = TextEditingController();
  // TextEditingController englishCont = TextEditingController();
  // TextEditingController volumeCont = TextEditingController();

  String youtubeEnglishLink = '';
  String youtubeUrduLink = '';
  // @override
  // void initState() {
  //   super.initState();
  //   init();
  // }
  //
  // Future<void> init() async {
  //   isUpdate = widget.data != null;
  //
  //   if (isUpdate) {
  //
  //   }
  //
  //   // /// Load categories
  //   // categories = await categoryService.categoriesFuture();
  //   //
  //   // if (categories.isNotEmpty) {
  //   //   if (isUpdate) {
  //   //     try {
  //   //       selectedCategory = categories.firstWhere((element) => element.id == widget.data!.categoryRef!.id);
  //   //     } catch (e) {
  //   //       print(e);
  //   //     }
  //   //   } else {
  //   //     selectedCategory = categories.first;
  //   //   }
  //   // }
  //
  //   setState(() {});
  // }

  // Future<void> save() async {
  //   if (formKey.currentState!.validate()) {
  //     HadeesData hadeesData = HadeesData();
  //     hadeesData.baab = baabCont.text.trim();
  //     hadeesData.bookInArabic = bookInArabicCont.text.trim();
  //     hadeesData.arabic = arabicCont.text.trim();
  //
  //
  //     hadeesData.updatedAt = DateTime.now();
  //
  //     if (isUpdate) {
  //       // hadeesData.id = widget.data!.id;
  //       hadeesData.createdAt = widget.data!.createdAt;
  //
  //       await sahihMuslimHadeesService
  //           .updateDocument(hadeesData.toJson(), hadeesData.sNo.toString())
  //           .then((value) {
  //         toast('Update Successfully');
  //         finish(context);
  //       }).catchError((e) {
  //         toast(e.toString());
  //       });
  //     } else {
  //       hadeesData.createdAt = DateTime.now();
  //
  //       sahihMuslimHadeesService.addDocument(hadeesData.toJson()).then((value) {
  //         toast('Add Question Successfully');
  //
  //         sNoCont.clear();
  //         hadithNoCont.clear();
  //         kitabCont.clear();
  //         kitabIdCont.clear();
  //         baabIdCont.clear();
  //         baabCont.clear();
  //         bookInArabicCont.clear();
  //         bookInEnglishCont.clear();
  //         bookInUrduCont.clear();
  //         arabicCont.clear();
  //         urduCont.clear();
  //         englishCont.clear();
  //         volumeCont.clear();
  //
  //         setState(() {});
  //       }).catchError((e) {
  //         log(e);
  //       });
  //     }
  //   }
  // }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //     "Ayats order: ${widget.ayats.map((e) => e['ayatData']['data']['index']).toList()}");

    widget.ayats.sort((a, b) {
      final ayatNoA =
          double.tryParse(a['ayatData']['data']['index'].toString()) ?? 0;
      final ayatNoB =
          double.tryParse(b['ayatData']['data']['index'].toString()) ?? 0;
      return ayatNoA.compareTo(ayatNoB);
    });
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0.0,
        leading: isUpdate
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: black),
                onPressed: () {
                  finish(context);
                },
              )
            : null,
        title: Row(
          children: [
            Text('Ayat Details', style: boldTextStyle()),
          ],
        ),
        actions: [],
      ),
      body: Form(
        key: formKey,
        child: ListView.builder(
          itemCount: widget.ayats.length,
          itemBuilder: (context, index) {
            final ayat = widget.ayats[index];

            return _buildAyat(ayat);
          },
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }

  Widget _buildAyat(dynamic ayat) {
    final ayatNo = ayat['ayatData']['data']['no'];
    final surahName = ayat["ayatData"]["data"]["surahName"];
    final arabic = ayat['ayatData']['data']['arabic'];
    final urdu = ayat['ayatData']['data']['urdu'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,

        16.height,
        longInfoDetails(
          "Surah Name",
          TextDirection.ltr,
          surahName,
          TextDirection.rtl,
          "ArabicFonts",
          18,
        ),
        16.height,
        longInfoDetails(
          "Ayat No",
          TextDirection.ltr,
          ayatNo,
          TextDirection.rtl,
          "ArabicFonts",
          18,
        ),
        // Text(
        //   'Ayat NO: $ayatNo',
        // ),
        16.height,
        longInfoDetails(
          "Arabic",
          TextDirection.ltr,
          arabic,
          TextDirection.rtl,
          "ArabicFonts",
          18,
        ),
        16.height,
        longInfoDetails(
          "Urdu",
          TextDirection.ltr,
          urdu,
          TextDirection.rtl,
          "UrduFonts",
          18,
        ),
        16.height,
      ],
    ).paddingAll(16);
  }

  Widget shortInfoDetails(
      String label,
      TextDirection labelTextDirection,
      String value,
      TextDirection valueTextDirection,
      String fontFamily,
      double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          textDirection: labelTextDirection,
          style: TextStyle(fontFamily: "Poppins", fontSize: fontSize),
        ),
        Text(
          value,
          textDirection: valueTextDirection,
          style: TextStyle(fontFamily: fontFamily, fontSize: fontSize),
        ),
      ],
    );
  }

  Widget longInfoDetails(
      String label,
      TextDirection labelTextDirection,
      String value,
      TextDirection valueTextDirection,
      String fontFamily,
      double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              label,
              textDirection: labelTextDirection,
              style: TextStyle(fontFamily: fontFamily, fontSize: fontSize),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            value,
            textDirection: valueTextDirection,
            style: GoogleFonts.notoNastaliqUrdu(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
