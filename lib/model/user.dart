///User object, contains information such as name, lastName, etc
class User {
  final String name;
  final String lastName;
  final List<String> courses; //The courses that the user is enrolled in

  User({
    required this.name,
    required this.lastName,
    required this.courses,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      name: data['name'],
      lastName: data['lastName'],
      courses: List.from(data['courses']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastName': lastName,
      'courses': courses,
    };
  }
}
