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
      Course course = await CourseHandler.getCourse('VESK (AB-period)', firestore);
      //Update mock course
      await CourseHandler.updateLiterature(course, firestore);

      //Assert results
      for (String name in course.getBookName()){
        Set<String> daisyISBNs = await DaisyHandler.getISBN(course.code);
        assert(daisyISBNs.contains(course.getISBN(name).first));
        assert(course.getISBN(name).length <= 10);
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
