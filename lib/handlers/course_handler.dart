import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseHandler{

  static Future<Course> getCourse(String shortCode) async {
    QuerySnapshot query = await FirebaseFirestore.instance.collection('courseTest')
        .where('shortCode', isEqualTo: shortCode)
        .get();

    return Course.fromMap(query.docs[0].data() as Map<String, dynamic>);
  }

  static addCourse(Course course) async {
    FirebaseFirestore.instance.collection('courseTest')
        .add(course.toMap())
        .then((value) => print('Course added'));
  }
}