import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/HadeesData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

import '../main.dart';
import 'BaseService.dart';

class SahihBukhariHadeesService extends BaseService {
  SahihBukhariHadeesService() {
    // COMMENTED: Hadith books not in use
    // ref = db.collection('Books').doc('HadithBooks').collection('CompleteBukhari');
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

  Future<QuestionData> questionById(String? id) async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // return await ref!.where('id', isEqualTo: id).limit(1).get().then((x) {
    //   if (x.docs.isNotEmpty) {
    //     return QuestionData.fromJson(x.docs.first.data() as Map<String, dynamic>);
    //   } else {
    //     throw 'Not available';
    //   }
    // });
    throw 'Not available - Hadith books disabled';
  }

  Future<int> countHadees() async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // AggregateQuerySnapshot query = await ref!.count().get();
    // debugPrint('The number of Sahih Bukhari Hadees: ${query.count}');
    // return query.count!;
    return 0;
  }

  Future<List<HadeesData>> questionListFuture({DocumentReference? categoryRef, int limit = 100}) async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // Query? query;
    // if (categoryRef != null) {
    //   query = ref!.where('category', isEqualTo: categoryRef).orderBy(CommonKeys.hadithNo).limit(limit);
    // } else {
    //   query = ref!.orderBy(CommonKeys.hadithNo).limit(limit);
    // }
    // List<HadeesData> data = [];
    // try {
    //   data = await query.get().then((x) =>
    //       x.docs.map((y) =>
    //           HadeesData.fromJson(y.data() as Map<String, dynamic>)).toList());
    // } catch(ex){
    //   debugPrint(ex.toString());
    // }
    // return data;
    return [];
  }

  Query? getQuestionsList({DocumentReference? categoryRef}) {
    // COMMENTED: Hadith books not in use
    // Query? query;
    // if (categoryRef != null) {
    //   try {
    //     query = ref!.where('category', isEqualTo: categoryRef).orderBy(CommonKeys.hadithNo);
    //   } catch (ex) { debugPrint(ex.toString()); }
    // } else {
    //   query = ref!.orderBy(CommonKeys.hadithNo);
    // }
    // return query;
    return null;
  }
}
