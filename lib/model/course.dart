class Course extends Object {
  final String name;
  final String shortCode;
  final String code;
  Map<String, Set<String>> literature;

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
      );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'shortCode': shortCode,
      'code': code,
      'literature':
          literature.map((key, value) => MapEntry(key, (value.toList()))),
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
      result.addAll(i);
    }
    return result;
  }

  Set<String> getISBN(String name) {
    return literature[name]!;
  }

  void setLiterature(Map<String, Set<String>> literature) {
    this.literature = literature;
  }

  String toString() {
    return name + " " + shortCode + " " + code + " " + literature.toString();
  }
}
