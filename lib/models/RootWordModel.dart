import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class RootWordModel {
  String? id;
  String? rootWord;
  String? description;
  String? triLiteralWord;
  DateTime? createdAt;
  DateTime? updatedAt;

  RootWordModel({
    this.id,
    this.rootWord,
    this.description,
    this.triLiteralWord,
    this.createdAt,
    this.updatedAt,
  });

  factory RootWordModel.fromJson(Map<String, dynamic> json) {
    return RootWordModel(
      id: json[CommonKeys.id],
      rootWord: json[RootWordKeys.rootWord],
      description: json[RootWordKeys.description],
      triLiteralWord: json[RootWordKeys.triLiteralWord],
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

