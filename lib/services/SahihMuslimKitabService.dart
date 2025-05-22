import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/KitabData.dart';

import '../main.dart';
import 'BaseService.dart';

class SahihMuslimKitabService extends BaseService {
  SahihMuslimKitabService() {
      ref = db.collection('Books').doc('HadithBooks').collection('SahihMuslimKitab');

  }

  Stream<List<KitabData>> kitablist() {
    return ref!.snapshots().map((x) => x.docs.map((y) => KitabData.fromJson(y.data() as Map<String, dynamic>)).toList());
  }

  Future<List<KitabData>> kitabsFuture() async {
    return await ref!.orderBy('index').get().then((x) => x.docs.map((y) => KitabData.fromJson(y.data() as Map<String, dynamic>)).toList());
  }

  Future<CategoryData> getCategoryById(String? id) async {
    return await ref!.where('id', isEqualTo: id).get().then((x) {
      if (x.docs.isNotEmpty) {
        log(x.docs.first.id);
        return CategoryData.fromJson(x.docs.first.data() as Map<String, dynamic>);
      } else {
        throw '';
      }
    }).catchError((e) {
      throw e;
    });
  }
}
