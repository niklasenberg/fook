import 'package:flutter/services.dart';
import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';

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

  static loadCourses() async {

    // ByteData data = await rootBundle.load("assets/Kurser-copy.xlsx");
    // var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // var excel = Excel.decodeBytes(bytes, update: true);
    //
    // for (var table in excel.tables.keys) {
    //   print(table); //sheet Name
    //   print(excel.tables[table].maxCols);
    //   print(excel.tables[table].maxRows);
    //   for (var row in excel.tables[table].rows) {
    //     print("$row");
    //   }
    // }

  }
}