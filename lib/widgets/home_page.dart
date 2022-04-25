import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/course.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
          FutureBuilder(
              future: CourseHandler.getCourse('PROG1'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Course course = snapshot.data as Course;
                  return Text(
                    course.getLiterature().first,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Delivery error: ${snapshot.error.toString()}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: FloatingActionButton(
          onPressed: () => signOut(context), child: const Icon(Icons.logout)),
    );
  }
}

signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
}
