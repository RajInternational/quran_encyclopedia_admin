import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/services/BaseService.dart';

class QuizServices extends BaseService {
  QuizServices() {
    ref = db.collection('quiz');
  }

  Future<List<QuizData>> get quizList async {
    return await ref!.get().then((value) => value.docs.map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>)).toList());
  }
}
