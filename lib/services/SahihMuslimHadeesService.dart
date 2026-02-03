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
    // COMMENTED: Hadith books not in use
    // ref = db.collection('Books').doc('HadithBooks').collection('Sahih Muslim Hadith');
  }
  Future<List<HadeesData>> fetchAllHadees({int limit = 200}) async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // QuerySnapshot snapshot = await ref!.orderBy(CommonKeys.hadithNo).limit(limit).get();
    // return snapshot.docs.map((doc) => HadeesData.fromJson(doc.data() as Map<String, dynamic>)).toList();
    return [];
  }

  Stream<List<QuestionData>> listQuestion() {
    // COMMENTED: Hadith books Firebase fetching disabled
    // return ref!.snapshots().map((x) => x.docs.map((y) => QuestionData.fromJson(y.data() as Map<String, dynamic>)).toList());
    return Stream.value([]);
  }

  Query? getQuestions() {
    // COMMENTED: Hadith books not in use
    // return ref;
    return null;
  }

  Future<int> countHadees() async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // AggregateQuerySnapshot query = await ref!.count().get();
    // return query.count!;
    return 0;
  }

  Future<QuestionData> questionById(String? id) async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // return await ref!.where('id', isEqualTo: id).limit(1).get().then((x) { ... });
    throw 'Not available - Hadith books disabled';
  }

  Future<List<HadeesData>> questionListFuture(
      {DocumentReference? categoryRef, int limit = 100}) async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // ... query and fetch from Firebase ...
    return [];
  }

  Query? getQuestionsList({DocumentReference? categoryRef}) {
    // COMMENTED: Hadith books not in use
    // return query;
    return null;
  }
}
