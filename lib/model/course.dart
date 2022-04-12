import 'dart:convert';

class Course {
  late final String name;
  late final String shortCode;
  late final String code;
  List<String> literature = [];

  Course({
    required this.name,
    required this.shortCode,
    required this.code,
    required this.literature,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        name: json["name"],
        shortCode: json["shortCode"],
        code: json["code"],
        literature: List.from(jsonDecode(json['literature'])),
      );

  getName() {
    return this.name;
  }
}
