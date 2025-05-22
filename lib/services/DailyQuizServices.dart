import 'dart:async';

import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/services/BaseService.dart';

class DailyQuizServices extends BaseService {
  DailyQuizServices() {
    ref = db.collection('dailyQuiz');
  }

  Future<QuizData> dailyQuestionListFuture(String id) async {
    return QuizData.fromJson(await ref!.doc(id).get().then((value) => value.data() as FutureOr<Map<String, dynamic>>));
  }
}
