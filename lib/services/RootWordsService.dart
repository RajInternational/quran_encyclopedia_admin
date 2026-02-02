import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/RootWordModel.dart';
import 'package:quizeapp/utils/ModelKeys.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../main.dart';
import 'BaseService.dart';

class RootWordsService extends BaseService {
  RootWordsService() {
    ref = db.collection('root_words');
  }

  /// Generate MD5 hash of rootWord
  String generateId(String rootWord) {
    var bytes = utf8.encode(rootWord.trim().toLowerCase());
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Query for pagination (orderBy required)
  Query getRootWordsQuery() {
    return ref!.orderBy(CommonKeys.createdAt, descending: true);
  }

  /// Get total count for pagination
  Future<int> getRootWordsCount() async {
    final snapshot = await getRootWordsQuery().count().get();
    return snapshot.count ?? 0;
  }

  /// Get root words with pagination (cursor-based)
  /// Returns map with 'items' (List<RootWordModel>) and 'lastDocument' (DocumentSnapshot?)
  Future<Map<String, dynamic>> getRootWordsPaginated({
    required int limit,
    DocumentSnapshot? startAfterDocument,
  }) async {
    Query query = getRootWordsQuery().limit(limit);
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }
    final snapshot = await query.get();
    final items = snapshot.docs
        .map((y) => RootWordModel.fromJson(
            y.data() as Map<String, dynamic>..[CommonKeys.id] = y.id))
        .toList();
    final lastDoc =
        snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    return {'items': items, 'lastDocument': lastDoc};
  }

  /// Stream all root words ordered by createdAt descending
  Stream<List<RootWordModel>> streamRootWords() {
    return ref!
        .orderBy(CommonKeys.createdAt, descending: true)
        .snapshots()
        .map((x) => x.docs
            .map((y) => RootWordModel.fromJson(
                y.data() as Map<String, dynamic>..[CommonKeys.id] = y.id))
            .toList());
  }

  /// Get all root words as Future
  Future<List<RootWordModel>> getRootWordsFuture() async {
    return await ref!
        .orderBy(CommonKeys.createdAt, descending: true)
        .get()
        .then((x) => x.docs
            .map((y) => RootWordModel.fromJson(
                y.data() as Map<String, dynamic>..[CommonKeys.id] = y.id))
            .toList());
  }

  /// Search root words by rootWord, triLiteralWord, or description (contains, case-insensitive)
  /// Fetches up to [fetchLimit] from Firestore and filters client-side
  Future<List<RootWordModel>> searchRootWords(
    String query, {
    int limit = 30,
    int fetchLimit = 500,
  }) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    final snapshot = await ref!
        .orderBy(CommonKeys.createdAt, descending: true)
        .limit(fetchLimit)
        .get();
    final all = snapshot.docs
        .map((y) => RootWordModel.fromJson(
            y.data() as Map<String, dynamic>..[CommonKeys.id] = y.id))
        .toList();
    final matches = all.where((w) {
      final rw = (w.rootWord ?? '').toLowerCase();
      final tri = (w.triLiteralWord ?? '').toLowerCase();
      final desc = (w.description ?? '').toLowerCase();
      final urduShort = (w.urduShortMeaning ?? '').toLowerCase();
      final engShort = (w.englishShortMeaning ?? '').toLowerCase();
      return rw.contains(q) ||
          tri.contains(q) ||
          desc.contains(q) ||
          urduShort.contains(q) ||
          engShort.contains(q);
    }).take(limit).toList();
    return matches;
  }

  /// Check if root word exists
  Future<bool> rootWordExists(String rootWord) async {
    String id = generateId(rootWord);
    final doc = await ref!.doc(id).get();
    return doc.exists;
  }

  /// Get root word by ID
  Future<RootWordModel?> getRootWordById(String id) async {
    try {
      final doc = await ref!.doc(id).get();
      if (doc.exists) {
        return RootWordModel.fromJson(
            doc.data() as Map<String, dynamic>..[CommonKeys.id] = doc.id);
      }
      return null;
    } catch (e) {
      log('Error getting root word: $e');
      return null;
    }
  }

  /// Add new root word
  Future<void> addRootWord(RootWordModel rootWord) async {
    try {
      if (rootWord.rootWord == null || rootWord.rootWord!.trim().isEmpty) {
        throw 'Root word cannot be empty';
      }

      String id = generateId(rootWord.rootWord!);

      // Check if root word already exists
      final exists = await rootWordExists(rootWord.rootWord!);
      if (exists) {
        throw 'Root word already exists';
      }

      rootWord.id = id;
      rootWord.createdAt = DateTime.now();
      rootWord.updatedAt = DateTime.now();

      await addDocumentWithCustomId(id, rootWord.toJson());
      log('Root word added successfully: $id');
    } catch (e) {
      log('Error adding root word: $e');
      rethrow;
    }
  }

  /// Update root word
  /// Note: Only description can be updated. Root word text cannot be changed.
  Future<void> updateRootWord(RootWordModel rootWord) async {
    try {
      if (rootWord.id == null || rootWord.id!.isEmpty) {
        throw 'Root word ID is required';
      }

      if (rootWord.rootWord == null || rootWord.rootWord!.trim().isEmpty) {
        throw 'Root word cannot be empty';
      }

      // Get existing root word
      final existing = await getRootWordById(rootWord.id!);
      if (existing == null) {
        throw 'Root word not found';
      }

      // Verify root word text hasn't changed (only description can be updated)
      if (existing.rootWord != rootWord.rootWord) {
        throw 'Root word text cannot be changed. Only description can be updated.';
      }

      // Update only description and updatedAt
      rootWord.updatedAt = DateTime.now();
      rootWord.createdAt = existing.createdAt; // Preserve original creation date
      await updateDocument(rootWord.toJson(), rootWord.id!);

      log('Root word updated successfully: ${rootWord.id}');
    } catch (e) {
      log('Error updating root word: $e');
      rethrow;
    }
  }

  /// Delete root word
  Future<void> deleteRootWord(String id) async {
    try {
      await removeDocument(id);
      log('Root word deleted successfully: $id');
    } catch (e) {
      log('Error deleting root word: $e');
      rethrow;
    }
  }
}

