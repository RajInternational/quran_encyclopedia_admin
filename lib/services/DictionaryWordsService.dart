import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordModel.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

import '../main.dart';
import 'BaseService.dart';

class DictionaryWordsService extends BaseService {
  DictionaryWordsService() {
    ref = db.collection('dictionary_words');
  }

  /// Stream all dictionary words ordered by createdAt descending
  Stream<List<DictionaryWordModel>> streamDictionaryWords() {
    return ref!
        .orderBy(CommonKeys.createdAt, descending: true)
        .snapshots()
        .map((x) => x.docs
            .map((y) => DictionaryWordModel.fromJson(
                y.data() as Map<String, dynamic>..[CommonKeys.id] = y.id))
            .toList());
  }

  /// Get all dictionary words as Future
  Future<List<DictionaryWordModel>> getDictionaryWordsFuture() async {
    return await ref!
        .orderBy(CommonKeys.createdAt, descending: true)
        .get()
        .then((x) => x.docs
            .map((y) => DictionaryWordModel.fromJson(
                y.data() as Map<String, dynamic>..[CommonKeys.id] = y.id))
            .toList());
  }

  /// Get dictionary word by ID
  Future<DictionaryWordModel?> getDictionaryWordById(String id) async {
    try {
      final doc = await ref!.doc(id).get();
      if (doc.exists) {
        return DictionaryWordModel.fromJson(
            doc.data() as Map<String, dynamic>..[CommonKeys.id] = doc.id);
      }
      return null;
    } catch (e) {
      log('Error getting dictionary word: $e');
      return null;
    }
  }

  /// Get dictionary words by rootHash
  Future<List<DictionaryWordModel>> getDictionaryWordsByRootHash(
      String rootHash) async {
    return await ref!
        .where(DictionaryWordKeys.rootHash, isEqualTo: rootHash)
        .orderBy(CommonKeys.createdAt, descending: true)
        .get()
        .then((x) => x.docs
            .map((y) => DictionaryWordModel.fromJson(
                y.data() as Map<String, dynamic>..[CommonKeys.id] = y.id))
            .toList());
  }

  /// Add new dictionary word
  Future<void> addDictionaryWord(DictionaryWordModel dictionaryWord) async {
    try {
      if (dictionaryWord.arabicWord == null ||
          dictionaryWord.arabicWord!.trim().isEmpty) {
        throw 'Arabic word cannot be empty';
      }

      if (dictionaryWord.rootHash == null ||
          dictionaryWord.rootHash!.trim().isEmpty) {
        throw 'Root word must be selected';
      }

      dictionaryWord.createdAt = DateTime.now();
      dictionaryWord.updatedAt = DateTime.now();

      final docRef = await addDocument(dictionaryWord.toJson());
      dictionaryWord.id = docRef.id;
      await updateDocument({CommonKeys.id: docRef.id}, docRef.id);

      log('Dictionary word added successfully: ${docRef.id}');
    } catch (e) {
      log('Error adding dictionary word: $e');
      rethrow;
    }
  }

  /// Update dictionary word
  Future<void> updateDictionaryWord(DictionaryWordModel dictionaryWord) async {
    try {
      if (dictionaryWord.id == null || dictionaryWord.id!.isEmpty) {
        throw 'Dictionary word ID is required';
      }

      if (dictionaryWord.arabicWord == null ||
          dictionaryWord.arabicWord!.trim().isEmpty) {
        throw 'Arabic word cannot be empty';
      }

      if (dictionaryWord.rootHash == null ||
          dictionaryWord.rootHash!.trim().isEmpty) {
        throw 'Root word must be selected';
      }

      dictionaryWord.updatedAt = DateTime.now();
      await updateDocument(dictionaryWord.toJson(), dictionaryWord.id!);

      log('Dictionary word updated successfully: ${dictionaryWord.id}');
    } catch (e) {
      log('Error updating dictionary word: $e');
      rethrow;
    }
  }

  /// Delete dictionary word
  Future<void> deleteDictionaryWord(String id) async {
    try {
      await removeDocument(id);
      log('Dictionary word deleted successfully: $id');
    } catch (e) {
      log('Error deleting dictionary word: $e');
      rethrow;
    }
  }
}

