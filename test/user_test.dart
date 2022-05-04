import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/course.dart';
import 'package:fook/model/user.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  final firestore = FakeFirebaseFirestore();

  //Populate mock firestore
  setUp(() async {
    await firestore.collection('courses').doc('0').set({
      'name': 'Programmering 1',
      'shortCode': 'PROG1',
      'code': 'IB133N',
      'literature': {'boken till prog1': ['isbn1', 'isbn2']},
      'isbnNumbers': ['123']
    });

    await firestore.collection('courses').doc('1').set({
      'name': 'PrototypkursN',
      'shortCode': 'PROTO',
      'code': 'IB711C',
      'literature': {'Prototyping:':  ['123', '124']},
      'isbnNumbers': ['123']
    });

    await firestore.collection('courses').doc('2').set({
      'name': 'Spelbaserat lärande',
      'shortCode': 'SL',
      'code': 'IB530C',
      'literature': {'placeholder':  ['456', '789']},
      'isbnNumbers': ['123']
    });

    await firestore.collection('users').doc('boomerFc').set({
      'name': 'Zlatan',
      'lastName': 'Ibrahamovic',
      'courses': ['PROG1', 'PROTO', 'SL'],
    });
  });

  group('User tests', () {
    test('Get UserName', () async {
      //Assert correct user fetch
      User user = await UserHandler.getUser('boomerFc', firestore);
      expect('Zlatan', user.getName());
    });

    test('Get user courses', () async {
      List<String> validCourses = ['PROG1', 'PROTO', 'SL'];

      //Fetch a specific users courses
      List<Course> userCourses = await CourseHandler.getUserCourses('boomerFc', firestore);

      for(Course course in userCourses){
        assert(validCourses.contains(course.shortCode));
      }
      //Assert correct result
      expect(userCourses.first.literature.keys.first, 'boken till prog1');
      expect(userCourses.first.literature['boken till prog1'], ['isbn1', 'isbn2']);

    });

    test('Update user courses', () async {
      //Fetch a specific users courses
      List<Course> userCourses = await CourseHandler.getUserCourses('boomerFc', firestore);

      expect(userCourses.first.literature.keys.first, 'boken till prog1');

      userCourses = await CourseHandler.updateUserCourses('boomerFc', firestore);

      //PROG1 doesnt have literature and should be empty
      assert(userCourses.first.literature.isEmpty);

      for(Course c in userCourses){
        if(c.shortCode == 'SL'){
          var name = await BookHandler.getBookName('9781118096345');
          expect(c.literature[name], {'9781118096345',
            '1118096347'});
        }else if (c.shortCode == 'PROTO'){
          var name = await BookHandler.getBookName('9144042035');
          expect(c.literature[name], {'9144042035',
            '9789144042039'});
        }
      }
    });
  });
}
