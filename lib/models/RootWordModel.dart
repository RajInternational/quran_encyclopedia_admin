import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class RootWordModel {
  String? id;
  String? rootWord;
  String? description;
  String? triLiteralWord;
  String? urduShortMeaning;
  String? englishShortMeaning;
  String? urduLongMeaning;
  String? englishLongMeaning;
  DateTime? createdAt;
  DateTime? updatedAt;

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

  factory RootWordModel.fromJson(Map<String, dynamic> json) {
    return RootWordModel(
      id: json[CommonKeys.id],
      rootWord: json[RootWordKeys.rootWord],
      description: json[RootWordKeys.description],
      triLiteralWord: json[RootWordKeys.triLiteralWord],
      urduShortMeaning: json[RootWordKeys.urduShortMeaning],
      englishShortMeaning: json[RootWordKeys.englishShortMeaning],
      urduLongMeaning: json[RootWordKeys.urduLongMeaning],
      englishLongMeaning: json[RootWordKeys.englishLongMeaning],
      createdAt: json[CommonKeys.createdAt] != null
          ? (json[CommonKeys.createdAt] as Timestamp).toDate()
          : null,
      updatedAt: json[CommonKeys.updatedAt] != null
          ? (json[CommonKeys.updatedAt] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson({bool toStore = true}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[CommonKeys.id] = this.id;
    data[RootWordKeys.rootWord] = this.rootWord;
    data[RootWordKeys.description] = this.description;
    data[RootWordKeys.triLiteralWord] = this.triLiteralWord;
    data[RootWordKeys.urduShortMeaning] = this.urduShortMeaning;
    data[RootWordKeys.englishShortMeaning] = this.englishShortMeaning;
    data[RootWordKeys.urduLongMeaning] = this.urduLongMeaning;
    data[RootWordKeys.englishLongMeaning] = this.englishLongMeaning;
    if (toStore) {
      data[CommonKeys.createdAt] = this.createdAt != null
          ? Timestamp.fromDate(this.createdAt!)
          : FieldValue.serverTimestamp();
      data[CommonKeys.updatedAt] = this.updatedAt != null
          ? Timestamp.fromDate(this.updatedAt!)
          : FieldValue.serverTimestamp();
    } else {
      data[CommonKeys.createdAt] = this.createdAt;
      data[CommonKeys.updatedAt] = this.updatedAt;
    }
    return data;
  }
}

