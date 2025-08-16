import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordData.dart';
import '../main.dart';
import 'BaseService.dart';

class DictionaryWordService extends BaseService {
  DictionaryWordService() {
    ref = db.collection('dictionary_words');
  }

  Stream<List<DictionaryWordData>> dictionaryWords() {
    return ref!.orderBy('createdAt', descending: true).snapshots().map((x) => 
        x.docs.map((y) => DictionaryWordData.fromJson(y.data() as Map<String, dynamic>)).toList());
  }

  Future<List<DictionaryWordData>> dictionaryWordsFuture() async {
    return await ref!.orderBy('createdAt', descending: true).get().then((x) => 
        x.docs.map((y) => DictionaryWordData.fromJson(y.data() as Map<String, dynamic>)).toList());
  }

  Future<DictionaryWordData> getDictionaryWordById(String? id) async {
    return await ref!.where('id', isEqualTo: id).get().then((x) {
      if (x.docs.isNotEmpty) {
        return DictionaryWordData.fromJson(x.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'Dictionary word not found';
      }
    }).catchError((e) {
      throw e;
    });
  }

  Future<void> addDictionaryWord(DictionaryWordData word) async {
    try {
      final data = word.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await addDocument(data);
      log('Dictionary word added successfully');
    } catch (e) {
      log('Error adding dictionary word: $e');
      throw e;
    }
  }

  Future<void> updateDictionaryWord(DictionaryWordData word) async {
    try {
      final data = word.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await updateDocument(data, word.id);
      log('Dictionary word updated successfully');
    } catch (e) {
      log('Error updating dictionary word: $e');
      throw e;
    }
  }

  Future<void> deleteDictionaryWord(String? id) async {
    try {
      await removeDocument(id);
      log('Dictionary word deleted successfully');
    } catch (e) {
      log('Error deleting dictionary word: $e');
      throw e;
    }
  }

  Future<List<DictionaryWordData>> searchDictionaryWords(String searchTerm) async {
    try {
      // Search in arabicWord field
      QuerySnapshot snapshot = await ref!
          .where('arabicWord', isGreaterThanOrEqualTo: searchTerm)
          .where('arabicWord', isLessThan: searchTerm + '\uf8ff')
          .orderBy('arabicWord')
          .get();
      
      return snapshot.docs.map((doc) => 
          DictionaryWordData.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      log('Error searching dictionary words: $e');
      return [];
    }
  }
}
