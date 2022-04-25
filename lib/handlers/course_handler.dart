import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseHandler{

  static Future<Course> getCourse(String courseCode) async {
    CollectionReference courseTest =
    FirebaseFirestore.instance.collection('courseTest');
    QuerySnapshot query =
    await courseTest.where('shortCode', isEqualTo: courseCode).get();

    return Course.fromMap(query.docs[0].data() as Map<String, dynamic>);

  }

  static addCourse(Course course) {
    CollectionReference courseTest =
    FirebaseFirestore.instance.collection('courseTest');

    courseTest.add(course.toMap()).then((value) => print('Course added'));
  }
}