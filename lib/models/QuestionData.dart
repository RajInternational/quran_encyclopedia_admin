import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class QuestionData {
  String? id;
  String? questionType;
  String? correctAnswer;
  String? note;
  String? questionTitle;
  bool? isChecked;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String>? optionList;

  DocumentReference? categoryRef;

  QuestionData({
    this.id,
    this.questionType,
    this.correctAnswer,
    this.note,
    this.questionTitle,
    this.categoryRef,
    this.isChecked = false,
    this.createdAt,
    this.updatedAt,
    this.optionList,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      id: json['id'],
      questionType: json['questionType'],
      correctAnswer: json['correctAnswer'],
      note: json['note'],
      questionTitle: json['addQuestion'],
      categoryRef: json[NewsKeys.categoryRef] != null ? (json[NewsKeys.categoryRef] as DocumentReference?) : null,
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
      updatedAt: json[CommonKeys.updatedAt] != null ? (json[CommonKeys.updatedAt] as Timestamp).toDate() : null,
      optionList: json['optionList'].cast<String>(),
    );
  }

  Map<String, dynamic> toJson({bool toStore = true}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['questionType'] = this.questionType;
    data['correctAnswer'] = this.correctAnswer;
    data['note'] = this.note;
    data['addQuestion'] = this.questionTitle;
    if (toStore) data[NewsKeys.categoryRef] = this.categoryRef;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    data['optionList'] = this.optionList;
    return data;
  }
}
