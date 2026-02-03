import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/KitabData.dart';

import '../main.dart';
import 'BaseService.dart';

class SahihMuslimKitabService extends BaseService {
  SahihMuslimKitabService() {
    // COMMENTED: Hadith books not in use
    // ref = db.collection('Books').doc('HadithBooks').collection('SahihMuslimKitab');
  }

  Stream<List<KitabData>> kitablist() {
    // COMMENTED: Hadith books Firebase fetching disabled
    // return ref!.snapshots().map((x) => x.docs.map((y) => KitabData.fromJson(y.data() as Map<String, dynamic>)).toList());
    return Stream.value([]);
  }

  Future<List<KitabData>> kitabsFuture() async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // return await ref!.orderBy('index').limit(50).get().then((x) => ...);
    return [];
  }

  Future<CategoryData> getCategoryById(String? id) async {
    // COMMENTED: Hadith books Firebase fetching disabled
    // return await ref!.where('id', isEqualTo: id).get().then((x) { ... });
    throw 'Hadith books disabled';
  }
}
