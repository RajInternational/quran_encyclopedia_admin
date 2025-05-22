import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/screens/admin/components/QuizItemWidget.dart';

class QuizListScreen extends StatefulWidget {
  static String tag = '/QuizListScreen';

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<QuizData>>(
        future: quizServices.quizList,
        builder: (_, snap) {
          if (snap.hasData) {
            if (snap.data!.isEmpty) return noDataWidget();

            return SingleChildScrollView(
              padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 60),
              child: Wrap(
                children: snap.data!.map((e) => QuizItemWidget(e)).toList(),
              ),
            );
          } else {
            return snapWidgetHelper(snap);
          }
        },
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
