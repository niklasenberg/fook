class Course extends Object{
  late final String name;
  late final String shortCode;
  late final String code;
  Map<String, List<String>> literature;

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
        literature: List.from(map['literature']),
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

  List<String> getLiterature() {
    return literature;
  }
}
