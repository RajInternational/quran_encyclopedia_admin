import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class HadeesData {
  // String? id;
  int? sNo;
  int? hadithNo;
  String? kitabId;
  String? kitab;
  String? baab;
  String? baabId;
  String? bookInEnglish;
  String? bookInArabic;
  String? bookInUrdu;
  String? arabic;
  String? urdu;
  String? english;
  String? volume;
  String? ravi;
  String? youtubeEnglishLink;
  String? youtubeUrduLink;
  DateTime? createdAt;
  DateTime? updatedAt;

  HadeesData({
    // this.id,
    this.sNo,
    this.hadithNo,
    this.kitabId,
    this.kitab,
    this.baabId,
    this.baab,
    this.bookInEnglish,
    this.bookInArabic,
    this.bookInUrdu,
    this.arabic,
    this.urdu,
    this.english,
    this.ravi,
    this.volume,
    this.youtubeEnglishLink,
    this.youtubeUrduLink,
    this.createdAt,
    this.updatedAt,
  });

  factory HadeesData.fromJson(Map<String, dynamic> json) {
    return HadeesData(
      // id: json['id'],
      sNo: json['sno'],
      hadithNo: json['hadithNo'],
      kitabId: json['kitabId'],
      kitab: json['kitab'],
      baabId: json['baabId'],
      baab: json['baab'],
      bookInEnglish: json['bookEnglish'],
      bookInArabic: json['bookArabic'],
      bookInUrdu: json['bookUrdu'],
      arabic: json['arabic'],
      urdu: json['urdu'],
      english: json['english'],
      ravi: json['ravi'],
      volume: json['volume'],
      youtubeEnglishLink: json['youtube_link_english'],
      youtubeUrduLink: json['youtube_link_urdu'],
      createdAt: json[CommonKeys.createdAt] != null
          ? json[CommonKeys.createdAt] is Timestamp
              ? (json[CommonKeys.createdAt] as Timestamp).toDate()
              : DateTime.parse(json[CommonKeys.createdAt] as String)
          : null,
      updatedAt: json[CommonKeys.updatedAt] != null
          ? json[CommonKeys.updatedAt] is Timestamp
              ? (json[CommonKeys.updatedAt] as Timestamp).toDate()
              : DateTime.parse(json[CommonKeys.updatedAt] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson({bool toStore = true}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['id'] = this.id;
    data['sno'] = this.sNo;
    data['hadithNo'] = this.hadithNo;
    data['kitabId'] = this.kitabId;
    data['kitab'] = this.kitab;
    data['baabId'] = this.baabId;
    data['baab'] = this.baab;
    data['bookEnglish'] = this.bookInEnglish;
    data['bookUrdu'] = this.bookInUrdu;
    data['bookArabic'] = this.bookInArabic;
    data['arabic'] = this.arabic;
    data['urdu'] = this.urdu;
    data['english'] = this.english;
    data['volume'] = this.volume;
    data['ravi'] = this.ravi;
    data['youtube_link_english'] = this.youtubeEnglishLink;
    data['youtube_link_urdu'] = this.youtubeUrduLink;
    data[CommonKeys.createdAt] = this.createdAt?.toIso8601String();
    data[CommonKeys.updatedAt] = this.updatedAt?.toIso8601String();
    return data;
  }
}
