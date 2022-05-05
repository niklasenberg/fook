import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/model/chat.dart';
import 'package:fook/widgets/chat_detailed_page.dart';
import 'package:fook/model/user.dart' as fook;

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text("Chats"),
      ),
      // key: _scaffKey,
      body: FutureBuilder(
        future: UserHandler.getUser(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (BuildContext context, AsyncSnapshot userDataSnapshot) {
          if (userDataSnapshot.hasData) {
            fook.User user = userDataSnapshot.data;
            String myId = FirebaseAuth.instance.currentUser!.uid;
            return StreamBuilder(
              stream: ChatHandler.getChats(
                  FirebaseAuth.instance.currentUser!.uid,
                  FirebaseFirestore.instance),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  QuerySnapshot qSnap = snapshot.data as QuerySnapshot;
                  List<DocumentSnapshot> docs = qSnap.docs;
                  if (docs.isEmpty)
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
                        future: _getChatterInfo(userId),
                        builder: (context, _snapshot) {
                          if (_snapshot.hasData) {
                            List<Object> infoList = (_snapshot.data as List<Object>);
                            infoList.add(userId);
                            DocumentSnapshot docSnapUser = infoList[0] as DocumentSnapshot;
                            fook.User otherUser = fook.User.fromMap(docSnapUser.data() as Map<String, dynamic>);

                            return Card(
                              margin: EdgeInsets.all(8.0),
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: InkWell(
                                splashColor:
                                    Theme.of(context).colorScheme.primary,
                                  onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailed(
                                      infoList
                                    ),
                                  ),
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  child: Center(
                                    child: Row(
                                      children: [
                                         Hero(
                                          tag: infoList[1].toString() + "1",
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    infoList[1].toString(),
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
                                            otherUser.name.toString(),
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
                                  valueColor: AlwaysStoppedAnimation(
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
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

_getChatterInfo(String userId) async {
  List<Object> result = [];
  result.add(await ChatHandler.getUserByUsername(
      userId,
      FirebaseFirestore.instance));
  result.add(await UserHandler.getPhotoUrl(userId, FirebaseFirestore.instance));

  return result;
}
Widget _timeDivider(Timestamp time) {
  DateTime t = time.toDate();
  String minute =
      t.minute > 9 ? t.minute.toString() : '0' + t.minute.toString();
  String ampm = t.hour >= 12 ? "PM" : "AM";
  int hour = t.hour >= 12 ? t.hour % 12 : t.hour;
  DateTime press = DateTime.now();
  if (press.year == t.year && press.month == t.month && press.day == t.day) {
    return Text(t.hour.toString() + ":" + t.minute.toString());
  }
  return Text(t.day.toString() +
      '/' +
      (t.month + 1).toString() +
      '/' +
      t.year.toString());
}
