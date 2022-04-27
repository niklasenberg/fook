import 'package:test/test.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/course.dart';
import 'package:fook/model/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fook/widgets/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fook/widgets/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('Book tests', () {
    test('Updated books', () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Course course = await CourseHandler.getCourse('EGOV');
      CourseHandler.updateLiterature(course);
    });
  });
}
