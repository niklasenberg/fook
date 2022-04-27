import 'dart:convert';

import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/daisy_handler.dart';
import 'dart:developer';

class CourseHandler {
  static Future<Course> getCourse(String shortCode) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('courseTest')
        .where('shortCode', isEqualTo: shortCode)
        .get();

    return Course.fromMap(query.docs[0].data() as Map<String, dynamic>);
  }

  static addCourse(Course course) async {
    FirebaseFirestore.instance
        .collection('courseTest')
        .add(course.toMap())
        .then((value) => print('Course added'));
  }

  static Future<bool> updateLiterature(Course course) async {
    Set<String> ISBNList = await DaisyHandler.getISBN(course.getCode());

    List<String> names = [];
    Map<String, Set<String>> result = {};
    for (var number in ISBNList) {
      names.add(await BookHandler.getBookName(number));
    }

    int index = 0;

    for (var name in names) {
      (result[name] as Set<String>).add(ISBNList.elementAt(index));
      result[name] = await BookHandler.getBookEditions(name);

      index++;
    }
    course.setLiterature(result);

    FirebaseFirestore.instance
        .collection('courseTest')
        .doc(await getCourseDocumentID(course.shortCode))
        .update(course.toMap());

    return true;
  }

  static Future<String> getCourseDocumentID(String shortCode) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('courseTest')
        .where('shortCode', isEqualTo: shortCode)
        .get();

    return query.docs[0].id;
  }
}
