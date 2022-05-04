import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/model/chat.dart';
import 'package:fook/widgets/chat_detailed_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text("Chats"),
      ),
      // key: _scaffKey,
      body: FutureBuilder(
        future: UserHandler.getInfo(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (BuildContext context, AsyncSnapshot userDataSnapshot) {
          if (userDataSnapshot.hasData) {
            Map<dynamic, dynamic> user = userDataSnapshot.data;
            String myId = user['uid'];
            return StreamBuilder(
              stream: ChatHandler.getUserByUsername(
                  FirebaseAuth.instance.currentUser!.uid,
                  FirebaseFirestore.instance),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  QuerySnapshot qSnap = snapshot.data as QuerySnapshot;
                  List<DocumentSnapshot> docs = qSnap.docs;
                  if (docs.length == 0)
                    return Center(
                      child: Text('No Chats yet!'),
                    );
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      List<dynamic> members = (docs[index].data()
                          as Map<String, dynamic>)['members'];
                      String userId;
                      userId = members.elementAt(0) == myId
                          ? members.elementAt(1)
                          : members.elementAt(0);
                      return FutureBuilder(
                        future: ChatHandler.getUserByUsername(
                            FirebaseAuth.instance.currentUser!.uid,
                            FirebaseFirestore.instance),
                        builder: (context, _snapshot) {
                          if (_snapshot.hasData) {
                            DocumentSnapshot docSnapUser =
                                _snapshot.data as DocumentSnapshot;
                            Map<String, dynamic> _user =
                                docSnapUser.data() as Map<String, dynamic>;
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: InkWell(
                                splashColor:
                                    Theme.of(context).colorScheme.primary,
                                /*onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatsDetailed(
                                      _user
                                    ),
                                  ),*/

                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Hero(
                                          tag: _user['photo'].toString(),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                fit: BoxFit.cover,
                                                image: new NetworkImage(
                                                  _user['photo'].toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.43,
                                          child: Text(
                                            _user['name'].toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: _timeDivider(
                                                (docs[index].data() as Map<
                                                    String,
                                                    dynamic>)['lastActive']),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Card(
                            margin: EdgeInsets.all(8.0),
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _timeDivider(Timestamp time) {
  DateTime t = time.toDate();
  String minute =
      t.minute > 9 ? t.minute.toString() : '0' + t.minute.toString();
  String ampm = t.hour >= 12 ? "PM" : "AM";
  int hour = t.hour >= 12 ? t.hour % 12 : t.hour;
  DateTime press = DateTime.now();
  if (press.year == t.year && press.month == t.month && press.day == t.day)
    return Text(hour.toString() + ':' + minute + ' ' + ampm);
  return Text(t.day.toString() +
      '/' +
      (t.month + 1).toString() +
      '/' +
      t.year.toString());
}
