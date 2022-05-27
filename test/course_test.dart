import 'package:fook/handlers/course_handler.dart';
import 'package:fook/handlers/daisy_handler.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fook/model/course.dart';
import 'dart:developer';

void main() {
  group('Course tests', () {
    test('Update literature', () async {

      //Populate mock firestore
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('courses').add({'name': 'Vetenskapligt skrivande',
        'code': 'IB141N',
        'shortCode': 'VESK (AB-period)',
        'literature': {'An Introduction to Design Science': ['9783030781323'],
            'The craft of research': ['9780226239873']}
      });

      //Get mock course
      List<Course> courses = [];
      courses.add(await CourseHandler.getCourse('VESK (AB-period)', firestore));
      courses.add(await CourseHandler.getCourse('EMDSV', firestore));

      //Update mock course
      await CourseHandler.updateCourses(courses, firestore);


      //Assert results
      for (Course course in courses){
        Set<String> daisyISBNs = await DaisyHandler.getISBN(course.code);

        if(course.getISBN(course.name).isNotEmpty){
          assert(daisyISBNs.contains(course.getISBN(course.name).first));
          assert(course.getISBN(course.name).length <= 10);
        }
      }
    });

    test('Get non-existing course', () async {
      //Populate mock firestore
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('courses').add({'name': 'Vetenskapligt skrivande',
        'code': 'IB141N',
        'shortCode': 'VESK (AB-period)',
        'literature': {'An Introduction to Design Science': ['9783030781323'],
          'The craft of research': ['9780226239873']}
      });
      Course course = await CourseHandler.getCourse('I DONT EXIST', firestore);
      assert(course.name == '?');
    });

    test('Get existing course', () async {
      //Populate mock firestore
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('courses').add({'name': 'Vetenskapligt skrivande',
        'code': 'IB141N',
        'shortCode': 'VESK (AB-period)',
        'literature': {'An Introduction to Design Science': ['9783030781323'],
          'The craft of research': ['9780226239873']}
      });
      Course course = await CourseHandler.getCourse('VESK (AB-period)', firestore);
      log(course.name.toString());
      expect(course.name, 'Vetenskapligt skrivande');

    });
  });
}
