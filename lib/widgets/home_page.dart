import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/model/course.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  Course course = getCourse('PROG1');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text(course.getName()),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: FloatingActionButton(
          onPressed: () => signOut(context), child: const Icon(Icons.logout)),
    );
  }
}

signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
}

getCourse(String courseCode) async {
  CollectionReference courseTest =
      FirebaseFirestore.instance.collection('courseTest');
  QuerySnapshot query =
      await courseTest.where('shortCode', isEqualTo: courseCode).get();

  if (query.docs.isEmpty) {
    return 'No course found';
  } else {
    return Course.fromJson(query.docs[0].data() as Map<String, dynamic>);
  }
}
