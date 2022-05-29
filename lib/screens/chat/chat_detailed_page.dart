import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/screens/widgets/fook_logo_appbar.dart';
import 'package:fook/model/book.dart';
import '../../handlers/user_handler.dart';
import '../../utils.dart';

///Page showing chat interaction between two users regarding a specific sale
class ChatDetailed extends StatefulWidget {
  final Map<String, dynamic> infoMap;

  const ChatDetailed(this.infoMap, {Key? key}) : super(key: key);

  @override
  _ChatDetailedState createState() => _ChatDetailedState();
}

class _ChatDetailedState extends State<ChatDetailed> {
  //Information about seller and buyer, and their specific interaction
  late String chatId;
  late String myId, userId;
  late fook.User otherUser, thisUser;
  late String photoUrl; //other users photo, not used at this time

  //Information about book and sale object
  late Book book;
  late Sale sale;
  late String sellerId;
  late String saleISBN;
  late String saleId;

  //State controllers/helpers
  TextEditingController messageController = TextEditingController();
  final _scaffKey = GlobalKey<ScaffoldState>();
  bool isChatEmpty = false;
  bool messageSent = false;
  Timestamp past = Timestamp.fromDate(DateTime(2019));

  @override
  void initState() {
    super.initState();
    userId = widget.infoMap['userId'].toString();
    myId = FirebaseAuth.instance.currentUser!.uid;
    sale = widget.infoMap['sale'];
    chatId = widget.infoMap['chatId'].toString();
    photoUrl = widget.infoMap['photoUrl'].toString();
    book = widget.infoMap['book'];
    sellerId = widget.infoMap['sellerId'];
    saleISBN = widget.infoMap['saleISBN'];
    saleId = widget.infoMap["saleId"];
    otherUser = widget.infoMap['otherUser'];
    thisUser = widget.infoMap['thisUser'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const FookAppBar(
          implyLeading: true,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        key: _scaffKey,
        body: _chatForm());
  }

  //Widgets
  ///Main layout for detailed chat page
  Widget _chatForm() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        height: 50,
                        decoration: const BoxDecoration(),
                        child: book.info.imageLinks["smallThumbnail"] != null
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
                              ? (book.info.title + ':\n ' + book.info.subtitle)
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
                          text: TextSpan(children: [
                            TextSpan(
                                text: sellerId == myId ? "Buyer: " : "Seller: ",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12)),
                            TextSpan(
                                text:
                                    (otherUser.name + ' ' + otherUser.lastName),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                )),
                            const WidgetSpan(child: SizedBox(width: 5)),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  _reportDialog(otherUser, userId);
                                },
                                child: Icon(
                                  Icons.flag,
                                  color: Theme.of(context).highlightColor,
                                  size: 20,
                                ),
                              ),
                            )
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
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12)),
                            TextSpan(
                                text: sale.isbn == '0'
                                    ? 'Not available'
                                    : sale.condition,
                                style: const TextStyle(
                                  fontSize: 12,
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
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12)),
                            TextSpan(
                                text: (saleISBN).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
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
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12)),
                            TextSpan(
                                text: sale.isbn == '0'
                                    ? 'Not available'
                                    : sale.price.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                )),
                          ]),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.all(4),
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
            child: _chatBody(userId),
          ),
        ),
        const Divider(
          height: 1.0,
        ),
        FutureBuilder(
          future: ChatHandler.isChatEmpty(chatId, FirebaseFirestore.instance),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              isChatEmpty = snapshot.data as bool;
              if (isChatEmpty && !messageSent) {
                messageController =
                    TextEditingController(text: "Is the book still available?");
                return _messageComposer("Is the book still available?");
              }
            }
            return _messageComposer("");
          },
        )
      ],
    );
  }

  ///Textfield and send button which writes/sends messages
  Widget _messageComposer(String message) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('lib/assets/Fook_back_sm.png'), fit: BoxFit.fill),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                    fillColor: Colors.white, filled: true),
                controller: messageController,
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
                  messageSent = true;
                  await ChatHandler.sendMessage(
                      userId,
                      myId,
                      saleId,
                      message,
                      thisUser.name,
                      sellerId,
                      saleISBN,
                      FirebaseFirestore.instance);
                }
              },
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              shape: const CircleBorder(
                  side: BorderSide(width: 1, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  ///Chat body, which is updated in realtime via Stream
  StreamBuilder<QuerySnapshot> _chatBody(String userId) {
    return StreamBuilder(
      stream: ChatHandler.getMessages(chatId, FirebaseFirestore.instance),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!.docs.isNotEmpty
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot message = snapshot.data!.docs[index];
                    if (snapshot.data!.docs.length == 1) {
                      return Column(
                        children: [
                          _timeDivider(
                              (message.data() as Map<String, dynamic>)['time']),
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
                          _timeDivider(
                              (message.data() as Map<String, dynamic>)['time']),
                          _messageItem(message, context),
                          if (!_isSameDay(toPass,
                              (message.data() as Map<String, dynamic>)['time']))
                            _timeDivider(toPass),
                        ],
                      );
                    }
                    past = (message.data() as Map<String, dynamic>)['time'];
                    return _isSameDay(
                            (message.data() as Map<String, dynamic>)['time'],
                            toPass)
                        ? _messageItem(message, context)
                        : Column(
                            children: [
                              _messageItem(message, context),
                              _timeDivider(toPass),
                            ],
                          );
                  },
                )
              : const Center(child: Text("No messages yet!"));
        }
        return const Center(
          child: Text('Loading...'),
        );
      },
    );
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
                  right: 10,
                  left: 80.0,
                  bottom: 8.0,
                  top: 8.0,
                )
              : const EdgeInsets.only(
                  left: 10,
                  right: 80.0,
                  bottom: 8.0,
                  top: 8.0,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isDoubleDigit(ttime)
                    ? ttime.hour.toString() + ":" + ttime.minute.toString()
                    : ttime.hour.toString() + ":" '0' + ttime.minute.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                (message.data() as Map<String, dynamic>)['message'].toString(),
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.white,
                  fontSize: 16.0,
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.secondaryContainer
                : const Color.fromRGBO(158, 158, 158, 1),
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
          ),
        ),
      );
    }
  }

  ///Popup dialog for reporting other user
  _reportDialog(fook.User user, String userId) {
    TextEditingController reportController = TextEditingController();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 3),
            ),
            contentPadding: const EdgeInsets.only(top: 10.0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Report " + user.name + " " + user.lastName,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            label:
                                Text("Why do you want to report this person?"),
                          ),
                          controller: reportController,
                          expands: true,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).highlightColor),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColor),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                ),
                              ),
                              child: const Text('Send',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                if (reportController.text.isNotEmpty) {
                                  UserHandler.sendReport(
                                      userId,
                                      FirebaseAuth.instance.currentUser!.uid,
                                      reportController.text,
                                      FirebaseFirestore.instance);
                                  Navigator.pop(context);
                                  Utility.toastMessage(
                                      "Report sent", 2, Colors.green);
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  //Helper methods
  ///Given a timestamp, returns a formatted string
  Widget _timeDivider(Timestamp time) {
    DateTime t = time.toDate();
    return Text(t.day.toString() +
        ' ' +
        Constants.months.elementAt(t.month - 1) +
        ', ' +
        t.year.toString());
  }

  ///Given two timestamps, returns whether they occur on the same day
  ///Used to determine whether date or time (same day) should be displayed
  bool _isSameDay(Timestamp present, Timestamp past) {
    DateTime pastTime = past.toDate();
    DateTime presentTime = present.toDate();
    if (pastTime.year < presentTime.year) return false;
    if (pastTime.month < presentTime.month) return false;
    return pastTime.day == presentTime.day;
  }

  ///Given a DateTime, checks whether that consists of two digits
  bool _isDoubleDigit(DateTime ttime) {
    if (ttime.minute < 10) {
      return false;
    }
    return true;
  }
}

///Helper class containing all the months in a year
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
