import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/daisy_handler.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:firebase_auth/firebase_auth.dart';

class CourseHandler {
  static Future<Course> getCourse(
      String shortCode, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('courses')
        .where('shortCode', isEqualTo: shortCode)
        .get();

    if (query.docs.isNotEmpty) {
      return Course.fromMap(query.docs[0].data() as Map<String, dynamic>);
    } else {
      //This shouldn't happen
      return Course(
          code: '?',
          shortCode: '?',
          name: '?',
          literature: <String, Set<String>>{});
    }
  }

  static Future<List<Course>> getUserCourses(
      String uid, FirebaseFirestore firestore) async {
    fook.User user = await UserHandler.getUser(uid, firestore);
    List<String> shortCodes = user.courses;
    List<Course> result = [];
    for (String shortCode in shortCodes) {
      result.add(await CourseHandler.getCourse(shortCode, firestore));
    }

    return result;
  }


  static Future<List<Course>> updateUserCourses(String uid, FirebaseFirestore firestore) async {
    List<Course> courses = await getUserCourses(uid, firestore);

    for(Course course in courses){
      //Get current ISBN for course from Daisy
      Set<String> isbnList = await DaisyHandler.getISBN(course.getCode());

      //Use these ISBNs to get accurate names
      List<String> names = [];
      Map<String, Set<String>> result = {};
      for (var number in isbnList) {
        names.add(await BookHandler.getBookName(number));
      }

      //Use these names to get other book versions
      int index = 0;
      for (var name in names) {
        result[name] = {};
        result[name]!.add(isbnList.elementAt(index));
        result[name]!.addAll(await BookHandler.getBookEditions(name));
        index++;
      }

      //Update course object
      course.setLiterature(result);

      //Update database
      await firestore
          .collection('courses')
          .doc(await getCourseDocumentID(course.shortCode, firestore))
          .update(course.toMap());
    }

    return courses;
  }

  static Future<String> getCourseDocumentID(
      String shortCode, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('courses')
        .where('shortCode', isEqualTo: shortCode)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs[0].id;
    } else {
      return 'not found';
    }
  }

  static Future<List<Object>> getInfo(
      String uId, FirebaseFirestore firestore) async {
    List<Object> result = [];

    result.add(await UserHandler.getUser(
        FirebaseAuth.instance.currentUser!.uid, firestore));
    result.add(await UserHandler.getPhotoUrl(
        FirebaseAuth.instance.currentUser!.uid, firestore));

    return result;
  }
}
