import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/widgets/chats_page.dart';
import 'package:fook/model/course.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: _getInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Object> list = snapshot.data as List<Object>;
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.width * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                margin: EdgeInsets.all(8.0),
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          list[1] as String,
                        ),
                      ),
                      Text(
                        (list[0] as fook.User).name,
                      ),
                      Text(
                           list[2].toString(),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      MaterialButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: Text('Signout'),
                        textColor: Theme.of(context).colorScheme.onSecondary,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      MaterialButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChatsPage())),
                        child: Text('Chats'),
                        textColor: Theme.of(context).colorScheme.onSecondary,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('Loading Profile...'),
          );
        }
      },
    ));
  }
}

Future<List<Object>> _getInfo() async {

  List<Course> courses = await CourseHandler.updateUserCourses(FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);

  List<Object> result = [];
  result.add(await UserHandler.getUser(
      FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance));
  result.add(await UserHandler.getPhotoUrl(
      FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance));
  result.add(courses);

  return result;
}
