import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/widgets/chats_page.dart';
import 'package:fook/widgets/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
        body: FutureBuilder(
      future: UserHandler.getInfo(
          FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Object> list = snapshot.data as List<Object>;
          return Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
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
                        (list[0] as fook.User).name + " " + (list[0] as fook.User).lastName,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)
                        ),
                        onPressed: () => FirebaseAuth.instance.signOut().then(
                            (value) => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()))),
                        child: const Text('Signout'),
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
          return Center(
            child: Text('Loading Profile...',
              style: TextStyle(color: Theme.of(context).primaryColor
              ),),
          );
        }
      },
        ));
  }
}
