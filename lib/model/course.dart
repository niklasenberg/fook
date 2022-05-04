class Course extends Object {
  final String name;
  final String shortCode;
  final String code;
  Map<String, Set<String>> literature;
  Set<String> isbnNumbers;

  Course({
    required this.name,
    required this.shortCode,
    required this.isbnNumbers,
    required this.code,
    required this.literature,
  });

  factory Course.fromMap(Map<String, dynamic> map) => Course(
        name: map["name"],
        isbnNumbers: Set<String>.from(map['isbnNumbers'] ?? {}),
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
      'isbnNumbers': isbnNumbers.toList(),
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

  Set<String> getIsbnNumbers() {
    return isbnNumbers;
  }

  Set<String> getISBN(String name) {
    if(literature[name] != null){
      return literature[name]!;
    }else{
      return <String>{};
    }
  }

  void setLiterature(Map<String, Set<String>> literature) {
    this.literature = literature;
  }

  void setIsbnNumbers(Set<String> numbers){
    isbnNumbers = numbers;
  }

  String toString() {
    return name + " " + shortCode + " " + code + " " + literature.toString() + " " + isbnNumbers.toString();
  }
}
