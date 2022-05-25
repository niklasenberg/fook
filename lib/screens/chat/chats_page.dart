import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/screens/chat/chat_detailed_page.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/model/sale.dart';
import 'package:fook/model/book.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatsPage> {
  late String myId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title: const Text("MY CHATS", style: TextStyle(color: Colors.orange)),
          centerTitle: true,
          backgroundColor: Colors.white),
      // key: _scaffKey,
      body: Container(
        margin: const EdgeInsets.all(4),
        height: MediaQuery.of(context).size.height - 250,
        decoration: const BoxDecoration(
          image: DecorationImage(
              opacity: 0.025,
              scale: 1,
              image: AssetImage(
                "lib/assets/chat_vector.png",
              )),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.5, 0.5),
              blurRadius: 1,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xffeae6e6),
              Color(0xfffafafa),
              Color(0xfffaf4f4),
              Color(0xffe5e3e3)
            ],
          ),
        ),
        child: StreamBuilder(
          stream: ChatHandler.getChats(myId, FirebaseFirestore.instance),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              QuerySnapshot qSnap = snapshot.data as QuerySnapshot;
              List<DocumentSnapshot> docs = qSnap.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Text('No Chats yet!'),
                );
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  String chatId =
                      (docs[index].data() as Map<String, dynamic>)['chatId'];
                  List<dynamic> members =
                      (docs[index].data() as Map<String, dynamic>)['members'];
                  String userId;
                  String saleId =
                      (docs[index].data() as Map<String, dynamic>)['saleId'];
                  userId = members.elementAt(0) == myId
                      ? members.elementAt(1)
                      : members.elementAt(0);

                  return FutureBuilder(
                    future: _getInfo(userId, saleId, chatId, members),
                    builder: (context, _snapshot) {
                      if (_snapshot.hasData) {
                        Map<String, dynamic> infoMap =
                            (_snapshot.data as Map<String, dynamic>);
                        DocumentSnapshot docSnapUser =
                            infoMap['otherUser'] as DocumentSnapshot;
                        fook.User otherUser = fook.User.fromMap(
                            docSnapUser.data() as Map<String, dynamic>);
                        Sale sale = infoMap['sale'];
                        Book book = infoMap['book'];
                        String sellerId = infoMap['sellerId'];
                        String saleISBN = infoMap['saleISBN'];

                        if (sale.isbn == '0') {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: Card(
                                margin: const EdgeInsets.all(8.0),
                                elevation: 8.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: InkWell(
                                  splashColor:
                                      Theme.of(context).highlightColor,
                                  onLongPress: () =>
                                      _deleteDialog(context, chatId),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatDetailed(infoMap),
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(10.0),
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 100,
                                                  decoration:
                                                      const BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey,
                                                        offset: Offset(2.0,
                                                            2.0), // shadow direction: bottom right
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.network(book
                                                      .info
                                                      .imageLinks[
                                                          "smallThumbnail"]
                                                      .toString()),
                                                ),
                                                const SizedBox(height: 5),
                                                Flexible(
                                                  child: Text(
                                                    subtitleExists(
                                                            book.info.subtitle)
                                                        ? (book.info.title +
                                                            ':\n ' +
                                                            book.info.subtitle)
                                                        : (book.info.title),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    softWrap: false,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              ]),
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
                                          child: Center(
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text: sellerId == myId
                                                              ? "Buyer: "
                                                              : "Seller: ",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontSize: 16)),
                                                      TextSpan(
                                                          text: (otherUser
                                                                  .name +
                                                              ' ' +
                                                              otherUser
                                                                  .lastName),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          )),
                                                    ]),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text: "Condition: ",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontSize: 16)),
                                                      TextSpan(
                                                          text:
                                                              ('Not available'),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          )),
                                                    ]),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text: "ISBN: ",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontSize: 16)),
                                                      TextSpan(
                                                          text: (saleISBN),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          )),
                                                    ]),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text: "Price: ",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontSize: 16)),
                                                      TextSpan(
                                                          text:
                                                              ('Not available'),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          )),
                                                    ]),
                                                  ),
                                                ]),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.20,
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: Flexible ( child: _timeDivider(
                                                (docs[index].data() as Map<
                                                    String,
                                                    dynamic>)['lastActive']),)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                        }

                        return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: InkWell(
                                splashColor:
                                    Theme.of(context).highlightColor,
                                onLongPress: () =>
                                    _deleteDialog(context, chatId),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailed(infoMap),
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(10.0),
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 100,
                                                decoration: const BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      offset: Offset(2.0,
                                                          2.0), // shadow direction: bottom right
                                                    ),
                                                  ],
                                                ),
                                                child: book.info.imageLinks[
                                                            "smallThumbnail"] !=
                                                        null
                                                    ? Image.network(book
                                                        .info
                                                        .imageLinks[
                                                            "smallThumbnail"]
                                                        .toString())
                                                    : Image.asset(
                                                        "lib/assets/placeholderthumbnail.png"),
                                              ),
                                              const SizedBox(height: 5),
                                              Flexible(
                                                child: Text(
                                                  subtitleExists(
                                                          book.info.subtitle)
                                                      ? (book.info.title +
                                                          ':\n ' +
                                                          book.info.subtitle)
                                                      : (book.info.title),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  softWrap: false,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              )
                                            ]),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.02,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.43,
                                        child: Center(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                RichText(
                                                  text: TextSpan(children: <
                                                      TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            sale.userID == myId
                                                                ? "Buyer: "
                                                                : "Seller: ",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 16)),
                                                    TextSpan(
                                                        text: (otherUser.name +
                                                            ' ' +
                                                            otherUser.lastName),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                        )),
                                                  ]),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                RichText(
                                                  text: TextSpan(children: <
                                                      TextSpan>[
                                                    TextSpan(
                                                        text: "Condition: ",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 16)),
                                                    TextSpan(
                                                        text: (sale.condition)
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                        )),
                                                  ]),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "ISBN: ",
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fontSize: 16)),
                                                        TextSpan(
                                                            text: (sale.isbn)
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            )),
                                                      ]),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "Price: ",
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fontSize: 16)),
                                                        TextSpan(
                                                            text: (sale.price)
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            )),
                                                      ]),
                                                ),
                                              ]),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.17,
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: _timeDivider(
                                              (docs[index].data() as Map<String,
                                                  dynamic>)['lastActive']),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      }

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
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
        ),
      ),
    );
  }
}

_getInfo(
    String userId, String saleId, String chatId, List<dynamic> members) async {
  Map<String, dynamic> result = {};
  result['otherUser'] =
      await UserHandler.getUserSnapshot(userId, FirebaseFirestore.instance);
  result['photoUrl'] =
      await UserHandler.getPhotoUrl(userId, FirebaseFirestore.instance);
  result['thisUser'] = await UserHandler.getUserSnapshot(
      FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);
  result['sale'] =
      await SaleHandler.getSaleByID(saleId, FirebaseFirestore.instance);
  result['userId'] = userId;
  result['chatId'] = chatId;

  DocumentSnapshot documentSnapshotChat =
      await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
  result['saleISBN'] = ((documentSnapshotChat.data()
      as Map<String, dynamic>)['saleISBN'] as String);
  result['sellerId'] = ((documentSnapshotChat.data()
      as Map<String, dynamic>)['sellerId'] as String);
  result['saleId'] = ((documentSnapshotChat.data()
      as Map<String, dynamic>)['saleId'] as String);

  if ((result['sale'] as Sale).isbn != "0") {
    result['book'] = await BookHandler.getBook((result['sale'] as Sale).isbn);
  } else {
    result['book'] = await BookHandler.getBook((result['saleISBN'] as String));
  }

  result['subtitleExists'] =
      subtitleExists((result['book'] as Book).info.subtitle);
  return result;
}

bool subtitleExists(String subtitle) {
  if (subtitle != '') {
    return true;
  } else {
    return false;
  }
}

Widget _timeDivider(Timestamp time) {
  DateTime t = time.toDate();
  DateTime press = DateTime.now();
  if (press.year == t.year && press.month == t.month && press.day == t.day) {
    if(t.minute < 10){
      return Text(t.hour.toString() + ":" + '0' + t.minute.toString(),);
    }
    return Text(t.hour.toString() + ":" + t.minute.toString(),);
  }
  return Text(t.day.toString() +
      '/' +
      (t.month + 1).toString() +
      '/' +
      t.year.toString(),);
}

Future<void> _deleteDialog(BuildContext context, chatId) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
            side: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 3),
          ),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Delete chat?",
                    ),
                  ],
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "By doing so the chat is removed for" + otherUser.name,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),*/
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        child: Text('Yes'),
                        onPressed: () {
                          ChatHandler.deleteChat(
                              chatId, FirebaseFirestore.instance);
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
                        child: Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
}
