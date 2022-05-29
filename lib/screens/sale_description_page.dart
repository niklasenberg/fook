import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/handlers/chat_handler.dart';
import 'package:fook/screens/chat/chat_detailed_page.dart';
import 'package:fook/screens/widgets/sale_card.dart';
import '../handlers/user_handler.dart';
import '../model/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils.dart';
import 'widgets/fook_logo_appbar.dart';

///Page displaying information regarding a specific Sale object
class SaleDescription extends StatefulWidget {
  final Sale sale;

  const SaleDescription(this.sale, {Key? key}) : super(key: key);

  @override
  State<SaleDescription> createState() => _SaleDescriptionState();
}

class _SaleDescriptionState extends State<SaleDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const FookAppBar(
          implyLeading: true,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: FutureBuilder(
            future: _getInfo(widget.sale),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> infoList =
                    snapshot.data as Map<String, dynamic>;
                Book book = infoList["book"] as Book;
                fook.User seller = infoList["seller"] as fook.User;
                return Column(
                  children: [
                    _saleInfo(book, seller),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                    _sendMessageButton(),
                  ],
                );
              }
              return Container(
                  margin: const EdgeInsets.all(10),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary,
                  ))));
            }));
  }

  ///Card displaying all the information concerning the Sale object
  Widget _saleInfo(Book book, fook.User seller) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 4,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(4)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    width: 20,
                  ),
                  RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: "SELLER ",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20)),
                      TextSpan(
                          text: (seller.name + " " + seller.lastName)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          )),
                    ]),
                  ),
                ],
              ),
              saleCard(FirebaseAuth.instance.currentUser!.uid,
                  widget.sale.userID, widget.sale, seller, book, context),
              Column(children: [
                Row(children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: const TextSpan(
                            text: "Sellers description:",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ),
                    ],
                  ),
                ]),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.shade300,
                    ),
                    margin: const EdgeInsets.all(10),
                    width: double.infinity,
                    height: 100,
                    child: Column(
                      children: [
                        Flexible(
                          child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: widget.sale.description,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  )),
                            ]),
                          ),
                        ),
                      ],
                    ))
              ]),
            ],
          )),
    );
  }

  ///Button for sending user to chat with seller via [_sendMessage]
  Widget _sendMessageButton() {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.6,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        onPressed: () {
          _sendMessage();
        },
        child: const Text('Send message to seller'),
        textColor: Colors.white,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  ///Helper method to retrieve information for [_saleInfo]
  _getInfo(Sale sale) async {
    Map<String, dynamic> infoList = {};
    infoList["book"] = await BookHandler.getBook(sale.isbn);
    infoList["seller"] =
        await UserHandler.getUser(sale.userID, FirebaseFirestore.instance);
    return infoList;
  }

  ///Helper method for sending a message to seller
  _sendMessage() async {
    String myId = FirebaseAuth.instance.currentUser!.uid;

    if (myId != widget.sale.userID) {
      if (await ChatHandler.checkChatExists(myId, widget.sale.userID,
              widget.sale.saleID, FirebaseFirestore.instance) ==
          true) {
        //Hämta chatID, Hoppa till chatten, khalas
        String chatID = ChatHandler.generateChatId(myId, widget.sale.userID,
            widget.sale.saleID); //Behöver man ens denna?
        Map<String, dynamic> infoMap = await ChatHandler.getChatInfo(
            FirebaseAuth.instance.currentUser!.uid,
            widget.sale.userID,
            widget.sale.saleID,
            chatID,
            FirebaseFirestore.instance,
            FirebaseStorage.instance);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailed(infoMap),
          ),
        );
      } else {
        //Generera nytt chatID och chatt, förifyll medd, khalas
        String chatId = ChatHandler.generateChatId(
            myId, widget.sale.userID, widget.sale.saleID);
        Map<String, dynamic> infoMap = await ChatHandler.getChatInfo(
            FirebaseAuth.instance.currentUser!.uid,
            widget.sale.userID,
            widget.sale.saleID,
            chatId,
            FirebaseFirestore.instance,
            FirebaseStorage.instance);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailed(infoMap),
          ),
        );
      }
    } else {
      Utility.toastMessage("This is your book!", 2, Colors.red);
    }
  }
}
