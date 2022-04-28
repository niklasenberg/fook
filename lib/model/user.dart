import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui/firestore.dart';

import 'course.dart';

class User {
  final String name;
  final String lastName;
  final String userId;
  final List<Course> courses;
/*
Gör constructor som ser ut som datamodellen i firebase
*/
  User({
    required this.name,
    required this.lastName,
    required this.userId,
    required this.courses,
  });
//from map
  //factory User.fromFireStore(Documentsn) {}

  String getName() {
    return name;
  }

  String getlastName() {
    return lastName;
  }

  List<Course> returnCourses() {
    return courses;
  }

  //Setregisteredcourses?
  //Setusername?

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
  }
}
