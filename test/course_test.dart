import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/handlers/daisy_handler.dart';
import 'package:fook/model/book.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fook/model/course.dart';

void main() {
  final firestore = FakeFirebaseFirestore();
  group('Course tests', () {
    setUpAll(() async {
      await firestore.collection('courses').add({
        'name': 'Vetenskapligt skrivande',
        'code': 'IB141N',
        'shortCode': 'VESK (AB-period)',
        'literature': {
          'An Introduction to Design Science': ['9783030781323', '12345'],
          'The craft of research': ['9780226239873', '6789']
        },
        'isbnNumbers': ['9783030781323', '12345', '9780226239873', '6789']
      });

      await firestore.collection('courses').doc('1').set({
        'name': 'Some other course',
        'code': 'AB123N',
        'shortCode': 'OTHER',
        'literature': {
          'An Introduction to Design Science': ['9783030781323', '12345']
        },
        'isbnNumbers': ['9783030781323', '12345']
      });

      await firestore.collection('users').doc('boomerFc').set({
        'name': 'Zlatan',
        'lastName': 'Ibrahamovic',
        'courses': ['VESK (AB-period)']
      });
    });

    test('Get existing course', () async {
      Course course =
          await CourseHandler.getCourse('VESK (AB-period)', firestore);
      expect(course.name, 'Vetenskapligt skrivande');
    });

    test('Get non-existing course', () async {
      Course course = await CourseHandler.getCourse('I DONT EXIST', firestore);
      expect(course.name, '?');
    });

    test('Get user courses', () async {
      List<Course> courses =
          await CourseHandler.getUserCourses('boomerFc', firestore);
      expect(courses[0].name, 'Vetenskapligt skrivande');
    });

    test('Get courses for ISBN', () async {
      List<String> courses =
          await CourseHandler.getCoursesForIsbn('9783030781323', firestore);
      expect(courses, ['VESK (AB-period)', 'OTHER']);
    });

    test('Is isbn in courses', () async {
      //True
      assert(await CourseHandler.isIsbnInCourses('9783030781323', firestore));
      //False
      assert(!(await CourseHandler.isIsbnInCourses('1456', firestore)));
    });

    test('Update course literature', () async {
      //Get mock course
      List<Course> courses = [];
      courses.add(await CourseHandler.getCourse('VESK (AB-period)', firestore));

      //Course contains invalid isbn
      assert(courses[0].isbnNumbers.contains('12345'));

      //Update mock course
      await CourseHandler.updateCourses(courses, firestore);

      //Assert results
      for (Course course in courses) {
        Set<String> daisyISBNs = await DaisyHandler.getISBN(course.code);

        if (course.getISBN(course.name).isNotEmpty) {
          //Check that current ISBN is in correct index
          assert(daisyISBNs.contains(course.getISBN(course.name).first));
          //Check that ISBN is at least 10 characters long
          assert(course.getISBN(course.name).length >= 10);
          //Check that course no longer contains invalid isbn
          assert(!courses[0].isbnNumbers.contains('12345'));

          //Ensure all retrieved ISBNs are to the correct book
          List<String> bookTitles = course.literature.keys.toList();
          for (String isbn in course.isbnNumbers) {
            Book book = await BookHandler.getBook(isbn);
            assert(bookTitles
                .contains((book.info.title + " " + book.info.subtitle).trim()));
          }
        }
      }
    });

    test('Get course document ID', () async {
      expect('1', await CourseHandler.getCourseDocumentID('OTHER', firestore));
    });
  });
}
