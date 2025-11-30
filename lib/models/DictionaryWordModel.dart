import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class DictionaryWordModel {
  String? id;
  String? arabicWord;
  String? rootHash;
  DateTime? createdAt;
  DateTime? updatedAt;

  DictionaryWordModel({
    this.id,
    this.arabicWord,
    this.rootHash,
    this.createdAt,
    this.updatedAt,
  });

  factory DictionaryWordModel.fromJson(Map<String, dynamic> json) {
    return DictionaryWordModel(
      id: json[CommonKeys.id],
      arabicWord: json[DictionaryWordKeys.arabicWord],
      rootHash: json[DictionaryWordKeys.rootHash],
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
    data[DictionaryWordKeys.arabicWord] = this.arabicWord;
    data[DictionaryWordKeys.rootHash] = this.rootHash;
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

