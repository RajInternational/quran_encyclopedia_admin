import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore field names for root_words collection (self-contained).
class _RootWordKeys {
  static const String id = 'id';
  static const String rootWord = 'rootWord';
  static const String description = 'description';
  static const String triLiteralWord = 'triLiteralWord';
  static const String urduShortMeaning = 'urduShortMeaning';
  static const String englishShortMeaning = 'englishShortMeaning';
  static const String urduLongMeaning = 'urduLongMeaning';
  static const String englishLongMeaning = 'englishLongMeaning';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}

/// Local model for root word (read-only view). Fully independent of main app models.
class RootWordModel {
  final String? id;
  final String? rootWord;
  final String? description;
  final String? triLiteralWord;
  final String? urduShortMeaning;
  final String? englishShortMeaning;
  final String? urduLongMeaning;
  final String? englishLongMeaning;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RootWordModel({
    this.id,
    this.rootWord,
    this.description,
    this.triLiteralWord,
    this.urduShortMeaning,
    this.englishShortMeaning,
    this.urduLongMeaning,
    this.englishLongMeaning,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }

  factory RootWordModel.fromJson(Map<String, dynamic> json) {
    return RootWordModel(
      id: json[_RootWordKeys.id] as String?,
      rootWord: json[_RootWordKeys.rootWord] as String?,
      description: json[_RootWordKeys.description] as String?,
      triLiteralWord: json[_RootWordKeys.triLiteralWord] as String?,
      urduShortMeaning: json[_RootWordKeys.urduShortMeaning] as String?,
      englishShortMeaning: json[_RootWordKeys.englishShortMeaning] as String?,
      urduLongMeaning: json[_RootWordKeys.urduLongMeaning] as String?,
      englishLongMeaning: json[_RootWordKeys.englishLongMeaning] as String?,
      createdAt: _parseTimestamp(json[_RootWordKeys.createdAt]),
      updatedAt: _parseTimestamp(json[_RootWordKeys.updatedAt]),
    );
  }
}
