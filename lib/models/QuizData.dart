import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class QuizData {
  List<String?>? questionRef;
  int? minRequiredPoint;
  String? id;
  String? imageUrl;
  String? quizTitle;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? categoryId;
  int? quizTime;
  String? description;

  QuizData({
    this.id,
    this.questionRef,
    this.minRequiredPoint,
    this.imageUrl,
    this.quizTitle,
    this.updatedAt,
    this.createdAt,
    this.categoryId,
    this.quizTime,
    this.description,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      questionRef: json['questionRef'].cast<String>(),
      minRequiredPoint: json['minRequiredPoint'],
      id: json['id'],
      imageUrl: json['imageUrl'],
      quizTitle: json['quizTitle'],
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
      updatedAt: json[CommonKeys.updatedAt] != null ? (json[CommonKeys.updatedAt] as Timestamp).toDate() : null,
      categoryId: json['categoryId'] != null ? json['categoryId'] : '',
      quizTime: json['quizTime'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['questionRef'] = this.questionRef;
    data['minRequiredPoint'] = this.minRequiredPoint;
    data['imageUrl'] = this.imageUrl;
    data['quizTitle'] = this.quizTitle;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    data['categoryId'] = this.categoryId;
    data['quizTime'] = this.quizTime;
    data['description'] = this.description;
    return data;
  }
}
