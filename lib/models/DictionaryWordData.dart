import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class DictionaryWordData {
  String? id;
  String? arabicWord;
  String? description;
  String? reference;
  DateTime? createdAt;
  DateTime? updatedAt;

  DictionaryWordData({
    this.id,
    this.arabicWord,
    this.description,
    this.reference,
    this.createdAt,
    this.updatedAt,
  });

  factory DictionaryWordData.fromJson(Map<String, dynamic> json) {
    return DictionaryWordData(
      id: json[CommonKeys.id],
      arabicWord: json['arabicWord'],
      description: json['description'],
      reference: json['reference'],
      createdAt: json[CommonKeys.createdAt] != null 
          ? (json[CommonKeys.createdAt] is Timestamp 
              ? (json[CommonKeys.createdAt] as Timestamp).toDate()
              : DateTime.parse(json[CommonKeys.createdAt]))
          : null,
      updatedAt: json[CommonKeys.updatedAt] != null 
          ? (json[CommonKeys.updatedAt] is Timestamp 
              ? (json[CommonKeys.updatedAt] as Timestamp).toDate()
              : DateTime.parse(json[CommonKeys.updatedAt]))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[CommonKeys.id] = id;
    data['arabicWord'] = arabicWord;
    data['description'] = description;
    data['reference'] = reference;
    data[CommonKeys.createdAt] = createdAt?.toIso8601String();
    data[CommonKeys.updatedAt] = updatedAt?.toIso8601String();
    return data;
  }
}
