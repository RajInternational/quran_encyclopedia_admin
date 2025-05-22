import 'package:equatable/equatable.dart';

class KitabData extends Equatable {
  int? bookId;
  int? index;
  String? name;

  KitabData({this.bookId, this.name, this.index});

  factory KitabData.fromJson(Map<String, dynamic> json) {
    return KitabData(
      bookId: json['bookId'],
      index: json['index'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson({bool toStore = true}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bookId'] = this.bookId;
    data['index'] = this.index;
    data['name'] = this.name;
    return data;
  }

  @override
  List<dynamic> get props => [
        bookId,
        name,
      ];
}
