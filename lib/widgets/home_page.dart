import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: _update(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Course> courses = snapshot.data as List<Course>;
                return Text(
                  courses.toString(),
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
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const LoginPage()));
}

Future<List<Course>> _update() async {
  return await CourseHandler.updateUserCourses(FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);
}
