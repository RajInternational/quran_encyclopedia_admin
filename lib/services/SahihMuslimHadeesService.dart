import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/HadeesData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

import '../main.dart';
import 'BaseService.dart';

class SahihMuslimHadeesService extends BaseService {
  SahihMuslimHadeesService() {
    ref = db
        .collection('Books')
        .doc('HadithBooks')
        .collection('Sahih Muslim Hadith');
  }
  Future<List<HadeesData>> fetchAllHadees() async {
    QuerySnapshot snapshot = await ref!.get();
    return snapshot.docs
        .map((doc) => HadeesData.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<QuestionData>> listQuestion() {
    return ref!.snapshots().map((x) => x.docs
        .map((y) => QuestionData.fromJson(y.data() as Map<String, dynamic>))
        .toList());
  }

  Query? getQuestions() {
    return ref;
  }

  Future<int> countHadees() async {
    AggregateQuerySnapshot query = await ref!.count().get();
    debugPrint('The number of Sahih Muslim Hadees: ${query.count}');
    return query.count!;
  }

  Future<QuestionData> questionById(String? id) async {
    return await ref!.where('id', isEqualTo: id).limit(1).get().then((x) {
      if (x.docs.isNotEmpty) {
        return QuestionData.fromJson(
            x.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'Not available';
      }
    });
  }

  Future<List<HadeesData>> questionListFuture(
      {DocumentReference? categoryRef}) async {
    Query? query;

    if (categoryRef != null) {
      query = ref!.where('category', isEqualTo: categoryRef);
    } else {
      query = ref;
    }

    log(ref);
    log(query!.parameters);
    List<HadeesData> data = [];
    try {
      data = await query.get().then((x) => x.docs
          .map((y) => HadeesData.fromJson(y.data() as Map<String, dynamic>))
          .toList());
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return data;
  }

  Query? getQuestionsList({DocumentReference? categoryRef}) {
    Query? query;

    if (categoryRef != null) {
      try {
        query = ref!
            .where('category', isEqualTo: categoryRef)
            .orderBy(CommonKeys.hadithNo);
      } catch (ex) {
        debugPrint(ex.toString());
      }
    } else {
      query = ref!.orderBy(CommonKeys.hadithNo);
    }
    // log(query.toString());
    return query;
  }
}
