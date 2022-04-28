class User {
  final String name;
  final String lastName;
  final List<String> courses;

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

/*

  static Future<List<Course>> fetchCourses(dynamic courses) async {
    List<String> x = List.from(courses);
    List<Course> result = [];
    for (String a in x) {
      result.add(await CourseHandler.getCourse(a, FirebaseFirestore.instance));
    }
    return result;
  }*/

  String getName() {
    return name;
  }

  String getlastName() {
    return lastName;
  }

  List<String> returnCourses() {
    return courses;
  }

  //Setregisteredcourses?
  //Setusername?
/*
  void addCourse(Course x) {
    for (Course c in courses) {
      if (courses.contains(x)) {
        ('Course' + x.getName() + ' is already in your list of courses!');
      }
      courses.add(x);
    }
  }

  void removeCourse(Course x) {
    for (Course c in courses) {
      if (courses.contains(x)) {
        courses.remove(c);
        ('Course has been deleted from your list of courses!');
      }
      ('Course not in your list of courses!');
    }
  }*/
}
