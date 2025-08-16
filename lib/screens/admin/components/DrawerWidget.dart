import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/ListModel.dart';
import 'package:quizeapp/screens/admin/subject/form_screen.dart';
import 'package:quizeapp/screens/admin/subject/subject_detail_screen.dart';
import 'package:quizeapp/screens/admin/dictionary/DictionaryWordsListScreen.dart';
import 'package:quizeapp/screens/admin/dictionary/AddDictionaryWordScreen.dart';
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
        name: 'Dictionary Words',
        widget: DictionaryWordsListScreen(),
        imageAsset: 'assets/icons/allquestion.png',
      ),
    );
    list.add(
      ListModel(
        name: 'Add Dictionary Word',
        widget: AddDictionaryWordScreen(),
        imageAsset: 'assets/icons/addQuestion.png',
      ),
    );

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
