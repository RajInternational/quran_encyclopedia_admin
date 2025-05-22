import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/HadeesData.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../utils/Colors.dart';
import '../../../utils/Constants.dart';

class SahihBukhariHadeesDetailScreen extends StatefulWidget {
  final HadeesData? data;

  SahihBukhariHadeesDetailScreen({this.data});

  @override
  AddQuestionsScreenState createState() => AddQuestionsScreenState();
}

class AddQuestionsScreenState extends State<SahihBukhariHadeesDetailScreen> {
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

  String youtubeEnglishLink = '';
  String youtubeUrduLink = '';
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
      youtubeUrduLink = widget.data!.youtubeUrduLink.validate();
      youtubeEnglishLink = widget.data!.youtubeEnglishLink.validate();
    }

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
      HadeesData hadeesData = HadeesData();

      hadeesData.sNo = sNoCont.text.trim().toInt();
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
      hadeesData.updatedAt = DateTime.now();

      if (isUpdate) {
        // hadeesData.id = widget.data!.id;
        hadeesData.createdAt = widget.data!.createdAt;

        await sahihBukhariHadeesService
            .updateDocument(hadeesData.toJson(), hadeesData.sNo.toString())
            .then((value) {
          toast('Update Successfully');
          finish(context);
        }).catchError((e) {
          toast(e.toString());
        });
      } else {
        hadeesData.createdAt = DateTime.now();

        sahihBukhariHadeesService
            .addDocument(hadeesData.toJson())
            .then((value) {
          toast('Add Question Successfully');

          sNoCont.clear();
          hadithNoCont.clear();
          kitabCont.clear();
          kitabIdCont.clear();
          baabIdCont.clear();
          baabCont.clear();
          bookInArabicCont.clear();
          bookInEnglishCont.clear();
          bookInUrduCont.clear();
          arabicCont.clear();
          urduCont.clear();
          englishCont.clear();
          volumeCont.clear();

          setState(() {});
        }).catchError((e) {
          log(e);
        });
      }
    }
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
                icon: Icon(Icons.arrow_back, color: black),
                onPressed: () {
                  finish(context);
                },
              )
            : null,
        title: Row(
          children: [
            Text('Sahih Bukhari Hadees Details', style: boldTextStyle()),
          ],
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                AppButton(
                  padding: EdgeInsets.all(16),
                  child: Text('Listen In Urdu',
                      style: primaryTextStyle(color: white)),
                  color: colorPrimary,
                  onTap: () {
                    setState(() {
                      showUrduPlayer = true;
                      showEnglishPlayer = false;
                    });
                  },
                ),
                AppButton(
                  padding: EdgeInsets.all(16),
                  child: Text('Listen In English',
                      style: primaryTextStyle(color: white)),
                  color: colorPrimary,
                  onTap: () {
                    setState(() {
                      showUrduPlayer = false;
                      showEnglishPlayer = true;
                    });
                  },
                )
              ]),
              16.height,
              showUrduPlayer && youtubeUrduLink.isNotEmpty
                  ? Column(
                      children: [
                        // Container(height:300,
                        //     child:
                        youtubePlayer(youtubeUrduLink),
                        // ),
                        16.height,
                      ],
                    )
                  : SizedBox(),
              16.height,
              showEnglishPlayer && youtubeEnglishLink.isNotEmpty
                  ? Column(
                      children: [
                        // Container(height:300,
                        //     child:
                        youtubePlayer(youtubeEnglishLink),
                        // ),
                        16.height,
                      ],
                    )
                  : SizedBox(),
              longInfoDetails2("Arabic", TextDirection.ltr, arabicCont.text,
                  TextDirection.rtl, "ArabicFonts", 18),
              16.height,
              longInfoDetails2("Urdu", TextDirection.ltr, urduCont.text,
                  TextDirection.rtl, "UrduFonts", 18),
              16.height,
              longInfoDetails("English", TextDirection.ltr, englishCont.text,
                  TextDirection.ltr, "Poppins", 18),
              16.height,
              shortInfoDetails("S No", TextDirection.ltr, sNoCont.text,
                  TextDirection.ltr, "Poppins", 18),
              16.height,
              shortInfoDetails("Hadith No", TextDirection.ltr,
                  hadithNoCont.text, TextDirection.ltr, "Poppins", 18),
              16.height,
              shortInfoDetails("Kitab ID", TextDirection.ltr, kitabIdCont.text,
                  TextDirection.ltr, "Poppins", 18),
              16.height,
              shortInfoDetails("Kitab", TextDirection.ltr, kitabCont.text,
                  TextDirection.ltr, "Poppins", 18),
              16.height,
              shortInfoDetails("Baab ID", TextDirection.ltr, baabIdCont.text,
                  TextDirection.ltr, "Poppins", 18),
              16.height,
              shortInfoDetails("Baab", TextDirection.ltr, baabCont.text,
                  TextDirection.ltr, "Poppins", 18),
              16.height,
              shortInfoDetails("Book in Arabic", TextDirection.ltr,
                  bookInArabicCont.text, TextDirection.rtl, "ArabicFonts", 18),
              16.height,
              shortInfoDetails("Book in English", TextDirection.ltr,
                  bookInEnglishCont.text, TextDirection.ltr, "Poppins", 18),
              16.height,
              shortInfoDetails("Book in Urdu", TextDirection.ltr,
                  bookInUrduCont.text, TextDirection.rtl, "UrduFonts", 18),
              16.height,
            ],
          ).paddingAll(16),
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
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
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize,
              ),
            ),
          ],
        ));
  }

  Widget longInfoDetails2(
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
              // style: TextStyle(fontFamily: fontFamily, fontSize: fontSize),
              style: GoogleFonts.notoNastaliqUrdu(fontSize: fontSize),
            ),
          ],
        ));
  }

  Widget youtubePlayer(String url) {
    String videoId;
    videoId = convertUrlToVideoId(url);
    print(videoId);
    // YoutubePlayerController _controller = YoutubePlayerController(
    //
    //   params: const YoutubePlayerParams(
    //     showControls: true,
    //     mute: false,
    //     showFullscreenButton: true,
    //     loop: false,
    //   ),
    // );
    final _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      // params: const YoutubePlayerParams(showFullscreenButton: true),
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 4 / 3,
      builder: (context, player) {
        return Container(
            height: 500,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: player,
            ));

        //   Column(
        //   children: [
        //     player,
        //   ],
        // );
      },
    );

//     return YoutubePlayerBuilder(
//       player: YoutubePlayer(
//         controller: _controller,
// // showVideoProgressIndicator: true,
//         showVideoProgressIndicator: true,
//         liveUIColor: Colors.green,
//         // progressIndicatorColor: CustomColors.buttonColor,
//         // progressColors: ProgressBarColors(
//         //   playedColor: Colors.amber,
//         //   handleColor: Colors.amberAccent,
//         // ),
//       ),
//       builder: (context, player) {
//         return Column(
//           children: [
//             player,
//           ],
//         );
//       },
//     );
  }

  String convertUrlToVideoId(String url) {
    String parseUrl, videoId;
    RegExp regExp = new RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );

    final match = regExp.firstMatch(url)!.group(1);
    // if(url.contains("iframe")){
    //   parseUrl =  url.substring(url.indexOf('embed\/'), url.length);
    //   videoId =  parseUrl.replaceAll('embed\/', '');
    // } else{
    //   parseUrl =  url.substring(url.indexOf('si\/'), url.length);
    //   videoId =  parseUrl.replaceAll('si\/', '');
    // }

    // videoId= videoId.substring(0,11);
    return match!;
  }
}
