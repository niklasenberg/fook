import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/screens/chat/chat_detailed_page.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/model/sale.dart';
import 'package:fook/model/book.dart';
import 'package:fook/screens/widgets/rounded_app_bar.dart';
import '../../theme/colors.dart';

///The user's view of active chats
class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatsPage> {
  final String myId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: RoundedAppBar("MY CHATS", Theme.of(context).highlightColor, ""),
        body: _chatList());
  }

  ///List of active chats for user, updated in realtime via stream and
  ///sorted by last activity
  Widget _chatList() {
    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height - 235,
      decoration: BoxDecoration(
        image: const DecorationImage(
            opacity: 0.025,
            scale: 1,
            image: AssetImage(
              "lib/assets/chat_vector.png",
            )),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.5, 0.5),
            blurRadius: 1,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: CustomColors.fookGradient,
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
                userId = members.elementAt(0) == myId
                    ? members.elementAt(1)
                    : members.elementAt(0);
                Timestamp lastActive =
                    (docs[index].data() as Map<String, dynamic>)['lastActive'];
                String saleId =
                    (docs[index].data() as Map<String, dynamic>)['saleId'];
                return _chatCard(userId, saleId, chatId, lastActive);
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

  ///A card signifying a specific chat interaction between two users.
  ///Persists even on deletion of sale object
  Widget _chatCard(
      String userId, String saleId, String chatId, Timestamp lastActive) {
    return FutureBuilder(
      future: ChatHandler.getChatInfo(
          FirebaseAuth.instance.currentUser!.uid,
          userId,
          saleId,
          chatId,
          FirebaseFirestore.instance,
          FirebaseStorage.instance),
      builder: (context, _snapshot) {
        if (_snapshot.hasData) {
          Map<String, dynamic> infoMap =
              (_snapshot.data as Map<String, dynamic>);
          fook.User otherUser = infoMap['otherUser'];
          Sale sale = infoMap['sale'];
          Book book = infoMap['book'];
          String sellerId = infoMap['sellerId'];
          String saleISBN = infoMap['saleISBN'];

          return SizedBox(
              height: MediaQuery.of(context).size.height * 0.28,
              child: Card(
                margin: const EdgeInsets.all(5),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: myId == sellerId
                      ? BorderSide(
                          width: 4, color: Theme.of(context).primaryColor)
                      : const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: InkWell(
                  splashColor: Theme.of(context).highlightColor,
                  onLongPress: () => _deleteDialog(context, chatId),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailed(infoMap),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: book.info
                                              .imageLinks["smallThumbnail"] !=
                                          null
                                      ? Image.network(book
                                          .info.imageLinks["smallThumbnail"]
                                          .toString())
                                      : Image.asset(
                                          "lib/assets/placeholderthumbnail.png"),
                                ),
                                const SizedBox(height: 5),
                                Flexible(
                                  child: Text(
                                    book.info.subtitle.isNotEmpty
                                        ? (book.info.title +
                                            ':\n ' +
                                            book.info.subtitle)
                                        : (book.info.title),
                                    overflow: TextOverflow.ellipsis,
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
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.43,
                          child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  RichText(
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "Seller: ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 16)),
                                      TextSpan(
                                          text: sellerId == myId
                                              ? "Me"
                                              : (otherUser.name +
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
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "Condition: ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 16)),
                                      TextSpan(
                                          text: sale.isbn == '0'
                                              ? ('Not available')
                                              : sale.condition,
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
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "ISBN: ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 16)),
                                      TextSpan(
                                          text: saleISBN,
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
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "Price: ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 16)),
                                      TextSpan(
                                          text: sale.isbn == '0'
                                              ? ('Not available')
                                              : sale.price.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          )),
                                    ]),
                                  ),
                                ]),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.20,
                          child: Align(
                              alignment: Alignment.bottomRight,
                              child: _timeDivider(lastActive)),
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
  }
}

///Helper widget displaying last active date/time for chat
_timeDivider(Timestamp time) {
  DateTime t = time.toDate();
  DateTime press = DateTime.now();
  if (press.year == t.year && press.month == t.month && press.day == t.day) {
    if (t.minute < 10) {
      return Text(
        t.hour.toString() + ":" + '0' + t.minute.toString(),
      );
    }
    return Text(
      t.hour.toString() + ":" + t.minute.toString(),
    );
  }
  return Text(
    t.day.toString() + '/' + (t.month + 1).toString() + '/' + t.year.toString(),
  );
}

///Popup dialog for deletion of chat objects
_deleteDialog(BuildContext context, chatId) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            side: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 3),
          ),
          contentPadding: const EdgeInsets.only(top: 10.0),
          content: SizedBox(
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
                  children: const <Widget>[
                    Text(
                      "Delete chat?",
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
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
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.white)),
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
                    SizedBox(
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
                        child: const Text('No',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
}
