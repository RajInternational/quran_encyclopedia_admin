import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class SubCategoryData {
    String? id;
    String? name;
    String? image;
    DateTime? createdAt;
    DateTime? updatedAt;

    SubCategoryData({this.id, this.name, this.image, this.createdAt, this.updatedAt});

    factory SubCategoryData.fromJson(Map<String, dynamic> json) {
        return SubCategoryData(
            id: json['id'],
            name: json['name'],
            image: json['image'],
          createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
          updatedAt: json[CommonKeys.updatedAt] != null ? (json[CommonKeys.updatedAt] as Timestamp).toDate() : null,
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['name'] = this.name;
        data['image'] = this.image;
        data[CommonKeys.createdAt] = this.createdAt;
        data[CommonKeys.updatedAt] = this.updatedAt;
        return data;
    }
}