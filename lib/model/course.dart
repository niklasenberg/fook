import 'dart:convert';

class Course extends Object {
  late final String name;
  late final String shortCode;
  late final String code;
  Map<String, dynamic> literature;

  Course({
    required this.name,
    required this.shortCode,
    required this.code,
    required this.literature,
  });

  factory Course.fromMap(Map<String, dynamic> map) => Course(
        name: map["name"],
        shortCode: map["shortCode"],
        code: map["code"],
        literature: (map['literature'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, Set<String>.from(value))),
        //  categories: (snap.data[CAT as Map<String, dynamic>).map((key, value) => MapEntry(key, MyCategory.fromEntity(MyCategoryEntity.fromJson(value)))),
      );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'shortCode': shortCode,
      'code': code,
      'literature': literature
    };
  }

  String getName() {
    return name;
  }

  String getShortCode() {
    return shortCode;
  }

  String getCode() {
    return code;
  }

  List<String> getBookName() {
    return List.from(literature.keys);
  }

  List<String> getAllISBN() {
    List<String> result = [];
    for (var i in literature.values) {
      result.addAll(i as Set<String>);
    }
    return result;
  }

  Set<String> getISBN(String name) {
    return literature[name]!;
  }
}
