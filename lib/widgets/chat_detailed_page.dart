import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:fook/widgets/profile_page.dart';
import 'package:fook/model/user.dart' as fook;

class ChatDetailed extends StatefulWidget {
  List<Object> infoList;
  ChatDetailed(this.infoList, {Key? key}) : super(key: key);
  @override
  _ChatDetailedState createState() => _ChatDetailedState();
}

class _ChatDetailedState extends State<ChatDetailed> {
  late String myId, userId;
  late TextEditingController messageController;
  Timestamp past = Timestamp.fromDate(DateTime(2019));
  late String chatId;
  late String photoUrl;
  late fook.User otherUser;
  final _scaffKey = GlobalKey<ScaffoldState>();

  //final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    userId = widget.infoList[2].toString();
    myId = FirebaseAuth.instance.currentUser!.uid;
    chatId = ChatHandler.generateChatId(myId, userId);
    photoUrl = widget.infoList[1].toString();
    otherUser = fook.User.fromMap((widget.infoList[0] as DocumentSnapshot).data() as Map<String, dynamic>);
    /*offlineStorage.getUserInfo().then(
      (val) {
        setState(
          () {
            Map<dynamic, dynamic> user = val;
            userId = widget.userData['uid'].toString();
            myId = user['uid'].toString();
            chatId = ChatHandler.generateChatId(myId, userId);
            userData = widget.userData;
          },
        );
      },
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffKey,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: InkWell(
              /*onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              ),*/
              splashColor: Theme.of(context).colorScheme.primary,
              focusColor: Theme.of(context).colorScheme.primary,
              highlightColor: Theme.of(context).colorScheme.primary,
              hoverColor: Theme.of(context).colorScheme.primary,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  children: [
                    Hero(
                      tag: photoUrl,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.width * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              photoUrl,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Text(
                      otherUser.name + " " + otherUser.lastName,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    )
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: _chatBody(userId),
          ),
          Divider(
            height: 1.0,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
            child: _messageComposer(),
          ),
        ],
      ),
    );
  }

  Widget _messageComposer() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          /*child: InkWell(
            onTap: () => showDialog(
              // barrierDismissible: false,
              context: context,
              builder: (context) => _buildPopUpImagePicker(context),
            ),
            child: Icon(
              Icons.image,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),*/
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: messageController,
              /*decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                filled: true,
                hintText: "Type in your message",
              ),*/
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FloatingActionButton(
            onPressed: () async {
              String message = messageController.text;
              if (message.isNotEmpty) {
                messageController.clear();
                await ChatHandler.sendMessage(
                    userId, myId, true, message); //Path? Behövs bara om man ska skicka bilder
              }
            },
            child: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }

  StreamBuilder<QuerySnapshot> _chatBody(String userId) {
    return StreamBuilder(
      stream: ChatHandler.getChat(userId, myId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!.docs.length != 0
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot message = snapshot.data!.docs[index];
                    if (snapshot.data!.docs.length == 1) {
                      return Column(
                        children: [
                          _timeDivider((message.data() as Map<String, dynamic>)['time']),
                          _messageItem(message, context),
                        ],
                      );
                    }
                    if (index == 0) {
                      past = (message.data() as Map<String, dynamic>)['time'];
                      return _messageItem(message, context);
                    }
                    Timestamp toPass = past;
                    if (index == snapshot.data!.docs.length - 1) {
                      return Column(
                        children: [
                          _timeDivider((message.data() as Map<String, dynamic>)['time']),
                          _messageItem(message, context),
                          if (!sameDay(toPass, (message.data() as Map<String, dynamic>)['time']))
                            _timeDivider(toPass),
                        ],
                      );
                    }
                    past = (message.data() as Map<String, dynamic>)['time'];
                    return sameDay((message.data() as Map<String, dynamic>)['time'], toPass)
                        ? _messageItem(message, context)
                        : Column(
                            children: [
                              _messageItem(message, context),
                              _timeDivider(toPass),
                            ],
                          );
                  },
                )
              : Center(child: const Text("No messages yet!"));
        }
        return Center(
          child: Text('Loading...'),
        );
      },
    );
  }

  Widget _timeDivider(Timestamp time) {
    DateTime t = time.toDate();
    return Text(t.day.toString() +
        ' ' +
        Constants.months.elementAt(t.month - 1) +
        ', ' +
        t.year.toString());
  }

  bool sameDay(Timestamp present, Timestamp passt) {
    DateTime pastTime = passt.toDate();
    DateTime presentTime = present.toDate();
    if (pastTime.year < presentTime.year) return false;
    if (pastTime.month < presentTime.month) return false;
    return pastTime.day == presentTime.day;
  }

  _messageItem(DocumentSnapshot message, BuildContext context) {
    final bool isMe = (message.data() as Map<String, dynamic>)['from'] == myId;
    Timestamp time = (message.data() as Map<String, dynamic>)['time'];
    DateTime ttime = time.toDate();
    if ((message.data() as Map<String, dynamic>)['isText']) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          margin: isMe
              ? const EdgeInsets.only(
                  left: 80.0,
                  bottom: 8.0,
                  top: 8.0,
                )
              : const EdgeInsets.only(
                  right: 80.0,
                  bottom: 8.0,
                  top: 8.0,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ttime.hour.toString() + ":" + ttime.minute.toString(),
                style: TextStyle(
                  color: Color(0xfff0f696),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                (message.data() as Map<String, dynamic>)['message'].toString(),
                style: TextStyle(
                  color: isMe
                      ? Theme.of(context).colorScheme.onSecondary
                      : Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16.0,
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.secondaryVariant,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
          ),
        ),
      );
    }
    /*return FutureBuilder(
      future: ChatHandler.getURLforImage(message.data()['photo'].toString()),
      builder: (context, snapshot) {
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            margin: isMe
                ? EdgeInsets.only(
                    left: 80.0,
                    bottom: 8.0,
                    top: 8.0,
                  )
                : EdgeInsets.only(
                    right: 80.0,
                    bottom: 8.0,
                    top: 8.0,
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hour.toString() + ":" + minute.toString() + " " + ampm,
                  style: TextStyle(
                    color: Color(0xfff0f696),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                snapshot.hasData
                    ? InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewer(
                              snapshot.data.toString(),
                            ),
                          ),
                        ),
                        child: Hero(
                          tag: snapshot.data.toString(),
                          child: Container(
                            margin: EdgeInsets.all(4.0),
                            height: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data.toString()),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
              ],
            ),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.secondaryVariant,
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
            ),
          ),
        );
      },
    );*/
  }

  /*Widget _buildPopUpImagePicker(context) {
    PickedFile _imageFile;
    StorageUploadTask _taskUpload;
    bool uploadBool = false;
    double height = MediaQuery.of(context).size.height * 0.4;
    if (_taskUpload != null)
      _taskUpload.onComplete.then((value) async {
        StorageReference sRef = value.ref;
        String path = await sRef.getPath();
        await dbHelper.sendMessage(
            to: userId, from: myId, isText: false, path: path);
        Navigator.pop(context);
      });
    return StatefulBuilder(
      builder: (context, setState) => Align(
        alignment: Alignment.topCenter,
        child: Container(
          // padding: EdgeInsets.all(8.0),
          height: height,
          width: MediaQuery.of(context).size.width * .6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          margin: EdgeInsets.only(bottom: 50, left: 12, right: 12, top: 50),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (!uploadBool) ...[
                  if (_imageFile == null)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onPressed: () async {
                              PickedFile image = await _picker.getImage(
                                  source: ImageSource.gallery);
                              setState(() {
                                _imageFile = image;
                                height =
                                    MediaQuery.of(context).size.height * 0.6;
                              });
                            },
                            color: Theme.of(context).colorScheme.secondary,
                            child: Text('Image from Gallery'),
                          ),
                        ),
                      ),
                    ),
                  if (_imageFile == null)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onPressed: () async {
                              PickedFile image = await _picker.getImage(
                                  source: ImageSource.camera);
                              setState(() {
                                _imageFile = image;
                                height =
                                    MediaQuery.of(context).size.height * 0.6;
                              });
                            },
                            color: Theme.of(context).colorScheme.secondary,
                            child: Text('Image from Camera'),
                          ),
                        ),
                      ),
                    ),
                  if (_imageFile != null)
                    Container(
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height * .4,
                      child: Image.file(
                        File(_imageFile.path),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  if (_imageFile != null)
                    SizedBox(
                      height: MediaQuery.of(context).size.width * .1,
                      child: Center(
                        child: MaterialButton(
                          color: Theme.of(context).colorScheme.secondary,
                          textColor: Theme.of(context).colorScheme.onSecondary,
                          onPressed: () => setState(() {
                            _imageFile = null;
                            height = MediaQuery.of(context).size.height * 0.4;
                          }),
                          child: Text('Clear Selection'),
                        ),
                      ),
                    ),
                  if (_imageFile != null)
                    SizedBox(
                      height: MediaQuery.of(context).size.width * .2,
                      child: Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: FloatingActionButton(
                            onPressed: () async {
                              if (_imageFile != null) {
                                _taskUpload = await dbHelper.uploadImage(
                                  image: File(_imageFile.path),
                                  to: userId,
                                  from: myId,
                                );
                                setState(() => uploadBool = true);
                              }
                            },
                            child: Icon(
                              Icons.send,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  StreamBuilder<StorageTaskEvent>(
                    stream: _taskUpload.events,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        StorageTaskEvent taskEvent = snapshot.data;
                        StorageTaskSnapshot event = snapshot.data.snapshot;
                        if (taskEvent.type == StorageTaskEventType.success) {
                          StorageReference sRef = event.ref;
                          sRef.getPath().then((path) async {
                            await dbHelper.sendMessage(
                                to: userId,
                                from: myId,
                                isText: false,
                                path: path);
                            Navigator.pop(context);
                          });
                        }
                      }
                      return Container(
                        height: MediaQuery.of(context).size.height * .5,
                        width: MediaQuery.of(context).size.width * .5,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }*/
}

class Constants {
  static List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
