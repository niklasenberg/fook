import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/model/constants.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/screens/widgets/fook_logo_appbar.dart';
import 'package:fook/model/book.dart';
import 'package:fook/screens/widgets/sale_description_page.dart';

import '../../handlers/user_handler.dart';

class ChatDetailed extends StatefulWidget {
  final Map<String, dynamic> infoList;
  bool isChatEmpty = false;

  ChatDetailed(this.infoList, {Key? key}) : super(key: key);

  @override
  _ChatDetailedState createState() => _ChatDetailedState();
}

class _ChatDetailedState extends State<ChatDetailed> {
  late String myId, userId;
  late Sale sale;
  late TextEditingController messageController;
  Timestamp past = Timestamp.fromDate(DateTime(2019));
  late String chatId;
  late String photoUrl;
  late bool subtitleExists;
  late String sellerId;
  late String saleISBN;
  late fook.User otherUser, thisUser;
  late Book book;
  final _scaffKey = GlobalKey<ScaffoldState>();

  //final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    userId = widget.infoList['userId'].toString();
    myId = FirebaseAuth.instance.currentUser!.uid;
    sale = (widget.infoList['sale']);
    chatId = widget.infoList['chatId'].toString();
    photoUrl = widget.infoList['photoUrl'].toString();
    book = widget.infoList['book'];
    subtitleExists = widget.infoList['subtitleExists'];
    sellerId = widget.infoList['sellerId'];
    saleISBN = widget.infoList['saleISBN'];

    otherUser = fook.User.fromMap(
        (widget.infoList['otherUser'] as DocumentSnapshot).data()
            as Map<String, dynamic>);
    thisUser = fook.User.fromMap(
        (widget.infoList['thisUser'] as DocumentSnapshot).data()
            as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    SizedBox bookBox;
    if (sale.isbn != '0') {
      bookBox = bookDisplay(context);
    } else {
      bookBox = isNoBookDisplay(context);
    }
    return Scaffold(
      appBar: FookAppBar(
        implyLeading: true,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffKey,
      body: Column(
        children: [
          bookBox,
          Flexible(
            flex: 75,
            child: Container(
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
              child: _chatBody(userId),
            ),
          ),
          const Divider(
            height: 1.0,
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
              child: FutureBuilder(
                future: _isChatEmpty(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    widget.isChatEmpty = snapshot.data as bool;
                    if (widget.isChatEmpty) {
                      messageController = TextEditingController(
                          text: "Is the book still available?");
                      return _messageComposer("Is the book still available?");
                    }
                  }
                  return _messageComposer("");
                },
              )),
        ],
      ),
    );
  }

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
              child: TextFormField(
                decoration: const InputDecoration(
                    fillColor: Colors.white, filled: true),
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
                      userId,
                      myId,
                      sale.saleID,
                      true,
                      message,
                      thisUser.name,
                      sale.userID,
                      sale.isbn,
                      FirebaseFirestore
                          .instance); //Path? Behövs bara om man ska skicka bilder
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

  isNoBookDisplay(BuildContext context) {
    return SizedBox(
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
                    margin: EdgeInsets.all(4),
                    height: 50,
                    decoration: const BoxDecoration(),
                    child: book.info.imageLinks["smallThumbnail"] != null ? Image.network(
                        book.info.imageLinks["smallThumbnail"].toString()) : Image.asset(
                        "lib/assets/placeholderthumbnail.png"),
                  ),
                  const SizedBox(height: 5),
                  Flexible(
                    child: Text(
                      subtitleExists
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
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: sellerId == myId ? "Buyer: " : "Seller: ",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12)),
                        TextSpan(
                            text: (otherUser.name + ' ' + otherUser.lastName),
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
                            text: "Condition: ",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12)),
                        const TextSpan(
                            text: ('Not available'),
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
                            text: ('Not available'),
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
    );
  }

  bookDisplay(BuildContext context) {
    return SizedBox(
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
                    margin: EdgeInsets.all(4),
                    height: 50,
                    decoration: const BoxDecoration(),
                    child: book.info.imageLinks["smallThumbnail"] != null ? Image.network(
                        book.info.imageLinks["smallThumbnail"].toString()) : Image.asset(
                        "lib/assets/placeholderthumbnail.png"),
                  ),
                  const SizedBox(height: 5),
                  Flexible(
                    child: Text(
                      subtitleExists
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
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: sale.userID == myId ? "Buyer: " : "Seller: ",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12)),
                        TextSpan(
                            text: (otherUser.name + ' ' + otherUser.lastName),
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
                            text: "Condition: ",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12)),
                        TextSpan(
                            text: (sale.condition).toUpperCase(),
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
                            text: (sale.isbn).toUpperCase(),
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
                            text: (sale.price).toString(),
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
    );
  }

  StreamBuilder<QuerySnapshot> _chatBody(String userId) {
    return StreamBuilder(
      stream: ChatHandler.getChat(chatId, FirebaseFirestore.instance),
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
                          if (!sameDay(toPass,
                              (message.data() as Map<String, dynamic>)['time']))
                            _timeDivider(toPass),
                        ],
                      );
                    }
                    past = (message.data() as Map<String, dynamic>)['time'];
                    return sameDay(
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

  _reportDialog(fook.User user, String userId) {
    TextEditingController reportController =
    TextEditingController();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 3),
            ),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
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
                        "Report " + user.name + " " + user.lastName,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                            label: Text("Why do you want to report this person?"),
                          ),
                          controller: reportController,
                          expands: true,
                          maxLines: null,
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
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
                              child: Text(
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
                          Container(
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
                              child: Text('Send', style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                if(reportController.text.isNotEmpty){
                                  UserHandler.sendReport(userId, FirebaseAuth.instance.currentUser!.uid, reportController.text, FirebaseFirestore.instance);
                                  Navigator.pop(context);
                                  toastMessage("Report sent", 2);
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

  Widget _timeDivider(Timestamp time) {
    DateTime t = time.toDate();
    return Text(t.day.toString() +
        ' ' +
        Constants.months.elementAt(t.month - 1) +
        ', ' +
        t.year.toString());
  }

  bool sameDay(Timestamp present, Timestamp past) {
    DateTime pastTime = past.toDate();
    DateTime presentTime = present.toDate();
    if (pastTime.year < presentTime.year) return false;
    if (pastTime.month < presentTime.month) return false;
    return pastTime.day == presentTime.day;
  }

  _isChatEmpty() async {
    var query = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    if (query.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
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
                isDoubleDigit(ttime)
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

  bool isDoubleDigit(DateTime ttime) {
    if (ttime.minute < 10) {
      return false;
    }

    return true;
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
