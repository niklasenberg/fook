import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/daisy_handler.dart';
import 'package:fook/model/user.dart' as fook;
import '../model/book.dart';

///Handler class that fetches/writes data concerning the courses in the database.
///Makes use of DaisyHandler and BookHandler to do so
class CourseHandler {
  ///Given a course shortCode, return a Course object. If no such Course exists, return a dummy object.
  static Future<Course> getCourse(
      String shortCode, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('courses')
        .where('shortCode', isEqualTo: shortCode)
        .get();

    if (query.docs.isNotEmpty) {
      //Construct object
      return Course.fromMap(query.docs[0].data() as Map<String, dynamic>);
    } else {
      //Dummy object
      return Course(
          code: '?',
          shortCode: '?',
          name: '?',
          literature: <String, Set<String>>{},
          isbnNumbers: <String>{});
    }
  }

  ///Given a user Id, fetch Course objects for each course the user is enrolled to.
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

  ///Given an ISBN number, return a list of Course objects where the ISBN
  ///is used in the course literature
  static Future<List<String>> getCoursesForIsbn(
      String isbn, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('courses')
        .where('isbnNumbers', arrayContains: isbn)
        .get();

    List<String> result = [];
    for (DocumentSnapshot d in query.docs) {
      result.add((d.data() as Map<String, dynamic>)['shortCode']);
    }
    return result;
  }

  ///Given an ISBN number, checks if isbn is found in ANY course
  static Future<bool> isIsbnInCourses(
      String isbn, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('courses')
        .where('isbnNumbers', arrayContains: isbn)
        .get();

    if (query.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  ///Given a list of Course object, update the contents of these Courses both on the client and in the database.
  static Future<List<Course>> updateCourses(
      List<Course> courses, FirebaseFirestore firestore) async {
    for (Course course in courses) {
      //Get current ISBN for course from Daisy
      Set<String> isbnList = await DaisyHandler.getISBN(course.code);

      //Use these ISBNs to get accurate names
      List<String> names = [];
      Map<String, Set<String>> result = {};
      for (var number in isbnList) {
        if (number.isNotEmpty) {
          List<Book> books = await BookHandler.getNullableBook(number);
          if (books.isNotEmpty) {
            Book book = books[0];
            String name = (book.info.title + " " + book.info.subtitle).trim();
            if (name.isNotEmpty) {
              names.add(name);
            } else {
              names.add("noname");
            }
          }
        }
      }

      if (names.isNotEmpty) {
        //Use these names to get other book versions
        Set<String> numbers = {};
        int index = 0;
        for (var name in names) {
          result[name] = {};
          result[name]!.add(isbnList.elementAt(index));
          result[name]!.addAll(await BookHandler.getBookEditions(name));
          numbers.addAll(result[name]!);
          index++;
        }

        //Update course object
        course.setLiterature(result);
        course.setIsbnNumbers(numbers);

        //Update database
        await firestore
            .collection('courses')
            .doc(await getCourseDocumentID(course.shortCode, firestore))
            .update(course.toMap());
      }
    }

    return courses;
  }

  ///Given a course shorCode, return the Id for the document in the database.
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
}
