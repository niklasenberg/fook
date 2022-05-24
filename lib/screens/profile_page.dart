import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/screens/login_page.dart';
import 'package:fook/screens/widgets/sale_description_page.dart';

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
        body: StreamBuilder(
      stream: UserHandler.getUserStream(FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          fook.User user = fook.User.fromMap((snapshot.data as DocumentSnapshot).data() as Map<String, dynamic>);
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
                      FutureBuilder(
                        future: UserHandler.getPhotoUrl(
                            FirebaseAuth.instance.currentUser!.uid,
                            FirebaseFirestore.instance),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(snapshot.data as String),
                            );
                          }
                          return CircleAvatar(
                            radius: 40,
                          );
                        },
                      ),
                      Text(
                        user.name + " " + user.lastName,
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
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        onPressed: () {
                          updateBox(context, user);
                          },
                        child: const Text('Update'),
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

  Future updateBox(BuildContext context, fook.User user){
    TextEditingController nameController = TextEditingController(text: user.name);
    TextEditingController lastnameController = TextEditingController(text: user.lastName);

    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3),
        ),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.35,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Update user information:",
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
              ),
              SizedBox(
                height: 5.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: MediaQuery.of(context).size.width * 0.4,child:TextField(controller: nameController,),),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.4,child:TextField(controller: lastnameController,),),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                  color: Colors.black,
                                  width: MediaQuery.of(context).size.width * 0.3,
                                ),
                              ),
                            ),
                          ),
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                            shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                  color: Colors.black,
                                  width: MediaQuery.of(context).size.width * 0.3,
                                ),
                              ),
                            ),
                          ),
                          child: Text('Save'),
                          onPressed: () async {
                            if(nameController.text.isNotEmpty){
                              UserHandler.updateUsername(FirebaseAuth.instance.currentUser!.uid, nameController.text, lastnameController.text, FirebaseFirestore.instance);
                              Navigator.pop(context);
                            }else{
                              toastMessage("Fields can't be empty", 2);
                            }
                          },
                        ),
                      ),
                    ],)
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}

Future<List<Object>> _getPhoto(String uId, FirebaseFirestore firestore) async {
  List<Object> result = [];
  result.add(await UserHandler.getUser(uId, firestore));
  result.add(await UserHandler.getPhotoUrl(uId, firestore));

  return result;
}
