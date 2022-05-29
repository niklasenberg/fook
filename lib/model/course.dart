///Course class, contains information about course,
///such as the course literature
class Course {
  final String name; //Full course name, such as "Vetenskapligt skrivande"
  final String shortCode; //Short version of course name, such as "VESK"
  final String code; //Course code used by Daisy, such as "IB141N"
  Map<String, Set<String>> literature; //Map of book names -> Sets of ISBNs
  Set<String> isbnNumbers; //All ISBNs related with the course

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

  List<String> getCurrentIsbns() {
    List<String> result = [];
    for (String name in literature.keys) {
      result.add(literature[name]!
          .first); //Current ISBNs are always placed at this index
    }
    return result;
  }

  Set<String> getISBN(String name) {
    if (literature[name] != null) {
      return literature[name]!;
    } else {
      return <String>{};
    }
  }

  void setLiterature(Map<String, Set<String>> literature) {
    this.literature = literature;
  }

  void setIsbnNumbers(Set<String> numbers) {
    isbnNumbers = numbers;
  }

  @override
  bool operator ==(Object other) {
    return other is Course && other.shortCode == shortCode;
  }

  @override
  String toString() {
    return name +
        " " +
        shortCode +
        " " +
        code +
        " " +
        literature.toString() +
        " " +
        isbnNumbers.toString();
  }

  @override
  int get hashCode => shortCode.hashCode;
}
