import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/model/course.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder(
            future: getCourse('PROG1'),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                Course course = snapshot.data as Course;
                return Text(course.getLiterature().first,
                style: TextStyle(
                  color: Colors.white,
                ),);
              } else if(snapshot.hasError) {
                return Text('Delivery error: ${snapshot.error.toString()}',
                  style: TextStyle(
                    color: Colors.white,
                  ),);
              } else {
                return const CircularProgressIndicator();
              }
            })
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

Future<Course> getCourse(String courseCode) async {
  CollectionReference courseTest =
      FirebaseFirestore.instance.collection('courseTest');
  QuerySnapshot query =
      await courseTest.where('shortCode', isEqualTo: courseCode).get();

  return Course.fromJson(query.docs[0].data() as Map<String, dynamic>);

}
