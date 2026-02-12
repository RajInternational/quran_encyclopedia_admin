import 'package:cloud_firestore/cloud_firestore.dart';

import 'root_word_model.dart';

/// Firestore collection and field names (self-contained).
const String _kCollectionRootWords = 'root_words';
const String _kFieldCreatedAt = 'createdAt';

/// Arabic text normalization for search (tashkeel-insensitive).
/// Self-contained so this folder does not depend on app ArabicUtils.
class _ArabicNormalize {
  static final RegExp _stripRegex = RegExp(
    r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640\s]',
  );

  static String stripTashkeel(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll(_stripRegex, '');
  }

  static bool containsNormalized(String haystack, String needle) {
    if (needle.isEmpty) return true;
    final h = stripTashkeel(haystack);
    final n = stripTashkeel(needle);
    return h.contains(n);
  }
}

/// Fully independent Firestore service for fetching root words only.
/// Uses FirebaseFirestore.instance directly; no dependency on main app db or BaseService.
class RootWordsFirestoreService {
  RootWordsFirestoreService() : _ref = FirebaseFirestore.instance.collection(_kCollectionRootWords);

  final CollectionReference<Map<String, dynamic>> _ref;

  Query<Map<String, dynamic>> _query() {
    return _ref.orderBy(_kFieldCreatedAt, descending: true);
  }

  RootWordModel _docToModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return RootWordModel(id: doc.id);
    }
    final map = Map<String, dynamic>.from(data)..['id'] = doc.id;
    return RootWordModel.fromJson(map);
  }

  /// Get total count of root words (for pagination).
  Future<int> getRootWordsCount() async {
    final snapshot = await _query().count().get();
    return snapshot.count ?? 0;
  }

  /// Get root words with cursor-based pagination.
  /// Returns map with 'items' (List<RootWordModel>) and 'lastDocument' (DocumentSnapshot?).
  Future<Map<String, dynamic>> getRootWordsPaginated({
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDocument,
  }) async {
    Query<Map<String, dynamic>> q = _query().limit(limit);
    if (startAfterDocument != null) {
      q = q.startAfterDocument(startAfterDocument);
    }
    final snapshot = await q.get();
    final items = snapshot.docs.map(_docToModel).toList();
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    return {'items': items, 'lastDocument': lastDoc};
  }

  /// Search root words by rootWord, triLiteralWord, description, or short meanings.
  /// Fetches from Firestore (up to [fetchLimit]) and filters client-side with
  /// Arabic-normalized matching.
  Future<List<RootWordModel>> searchRootWords(
    String query, {
    int? limit,
    int fetchLimit = 10000,
  }) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim();
    final qLower = q.toLowerCase();
    final snapshot = await _query().limit(fetchLimit).get();
    final all = snapshot.docs.map(_docToModel).toList();
    final matches = all.where((w) {
      final rw = w.rootWord ?? '';
      final tri = w.triLiteralWord ?? '';
      final desc = (w.description ?? '').toLowerCase();
      final urduShort = (w.urduShortMeaning ?? '').toLowerCase();
      final engShort = (w.englishShortMeaning ?? '').toLowerCase();
      return _ArabicNormalize.containsNormalized(rw, q) ||
          _ArabicNormalize.containsNormalized(tri, q) ||
          desc.contains(qLower) ||
          urduShort.contains(qLower) ||
          engShort.contains(qLower);
    });
    return limit == null ? matches.toList() : matches.take(limit).toList();
  }
}
