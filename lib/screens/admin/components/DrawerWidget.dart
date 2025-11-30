import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/ListModel.dart';
import 'package:quizeapp/screens/admin/CategoryListScreen.dart';
import 'package:quizeapp/screens/admin/sahih_bukhari/SahihBukhariAddHadeesScreen.dart';
import 'package:quizeapp/screens/admin/sahih_bukhari/SahihBukhariHadeesListWidget.dart';
import 'package:quizeapp/screens/admin/sahih_muslim/SahihMuslimAddHadeesScreen.dart';
import 'package:quizeapp/screens/admin/sahih_muslim/SahihMuslimHadeesListWidget.dart';
import 'package:quizeapp/screens/admin/subject/form_screen.dart';
import 'package:quizeapp/screens/admin/subject/subject_detail_screen.dart';
import 'package:quizeapp/screens/admin/root_words/RootWordsView.dart';
import 'package:quizeapp/screens/admin/dictionary_words/DictionaryWordsView.dart';
import 'package:quizeapp/utils/Colors.dart';

class DrawerWidget extends StatefulWidget {
  static String tag = '/DrawerWidget';
  final Function(Widget?)? onWidgetSelected;

  DrawerWidget({this.onWidgetSelected});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  List<ListModel> list = [];

  int index = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // list.add(ListModel(name: 'Dashboard', widget: AdminStatisticsWidget(), iconData: AntDesign.dashboard));
    // list.add(ListModel(
    //     name: 'Category List',
    //     widget: CategoryListScreen(),
    //     imageAsset: 'assets/icons/category.png'));
    // list.add(ListModel(
    //   name: 'Sahih Muslim Hadees List',
    //   widget: SahihMuslimHadeesListWidget(),
    //   imageAsset: 'assets/icons/allquestion.png',
    // ));
    // list.add(ListModel(
    //     name: 'Add Sahih Muslim Hadees',
    //     widget: SahihMuslimAddHadeesScreen(),
    //     imageAsset: 'assets/icons/addQuestion.png'));
    // list.add(ListModel(
    //     name: 'Sahih Bukhari Hadees List',
    //     widget: SahihBukhariHadeesListWidget(),
    //     imageAsset: 'assets/icons/allquestion.png'));
    // list.add(
    //   ListModel(
    //     name: 'Add Sahih Bukhari Hadees',
    //     widget: SahihBukhariAddHadeesScreen(),
    //     imageAsset: 'assets/icons/addQuestion.png',
    //   ),
    // );
    list.add(
      ListModel(
        name: 'View Subject',
        widget: SubjectDetailScreen(),
        imageAsset: 'assets/icons/allquestion.png',
      ),
    );
    list.add(
      ListModel(
        name: 'Add Subject',
        widget: FormScreen(),
        imageAsset: 'assets/icons/addQuestion.png',
      ),
    );
    list.add(
      ListModel(
        name: 'Root Words',
        widget: RootWordsView(),
        imageAsset: 'assets/icons/allquestion.png',
      ),
    );
    list.add(
      ListModel(
        name: 'Dictionary Words',
        widget: DictionaryWordsView(),
        imageAsset: 'assets/icons/allquestion.png',
      ),
    );

    // list.add(ListModel(name: 'Daily Quiz', widget: DailyQuizScreen(), imageAsset: 'assets/icons/dailyQuiz.png'));
    // list.add(ListModel(name: 'Quiz List', widget: QuizListScreen(), imageAsset: 'assets/icons/allQuiz.png'));
    // list.add(ListModel(name: 'Create Quiz', widget: CreateQuizScreen(), imageAsset: 'assets/icons/createQuiz.png'));
    //list.add(ListModel(name: 'Import Question', widget: ImportQuestionScreen(), imageAsset: 'assets/icons/import.png'));
    //list.add(ListModel(name: 'Notifications', widget: NotificationScreen(), iconData: AntDesign.bells));
    // list.add(ListModel(name: 'Manage Users', widget: UserListScreen(), iconData: Feather.users));
    // list.add(ListModel(name: 'Settings', widget: AdminSettingScreen(), iconData: Feather.settings));

    LiveStream().on('selectItem', (index) {
      this.index = index as int;
      widget.onWidgetSelected?.call(list[this.index].widget);
      setState(() {});
    });

  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose('selectItem');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Wrap(
          children: list.map(
            (e) {
              int cIndex = list.indexOf(e);

              return SettingItemWidget(
                title: e.name!,
                leading: e.iconData != null
                    ? Icon(e.iconData,
                        color: cIndex == index ? colorPrimary : Colors.white,
                        size: 24)
                    : Image.asset(e.imageAsset!,
                        color: cIndex == index ? colorPrimary : Colors.white,
                        height: 24),
                titleTextColor: cIndex == index ? colorPrimary : Colors.white,
                decoration: BoxDecoration(
                  color: cIndex == index ? selectedDrawerItemColor : null,
                  //  border: Border.all(),
                  borderRadius: cIndex == index - 1
                      ? BorderRadius.only(
                          bottomRight: Radius.circular(24),
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24))
                      : cIndex == index + 1
                          ? BorderRadius.only(
                              topRight: Radius.circular(24),
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24))
                          : BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24)),
                ),
                onTap: () {
                  index = list.indexOf(e);
                  widget.onWidgetSelected?.call(e.widget);
                },
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
