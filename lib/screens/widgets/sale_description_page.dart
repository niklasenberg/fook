import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/handlers/chat_handler.dart';
import '../../handlers/user_handler.dart';
import '../../model/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/course.dart';
import 'fook_logo_appbar.dart';

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
        appBar: FookAppBar(
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 20)),
                                      TextSpan(
                                          text: (seller.name +
                                                  " " +
                                                  seller.lastName)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          )),
                                    ]),
                                  ),
                                ],
                              ),
                              SaleCard(widget.sale, seller, book, context),
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
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                ]),
                                Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
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
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        onPressed: () {
                          String myId = FirebaseAuth.instance.currentUser!.uid;
                          if(myId != widget.sale.userID){
                            ChatHandler.sendMessage(
                                widget.sale.userID,
                                myId,
                                widget.sale.saleID,
                                true,
                                'Tjena, finns varan',
                                seller.name + " " + seller.lastName,
                                FirebaseFirestore.instance);
                            toastMessage("Message sent, check your chats!", 2);
                          }else{
                            toastMessage("This is your book!", 2);
                          }
                        },
                        child: const Text('Send message to seller'),
                        textColor: Colors.white,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
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
}

Widget SaleCard(Sale sale, fook.User seller, Book book, context) {
  Color background = Colors.grey.shade300;
  Color fill = Theme.of(context).backgroundColor;
  final List<Color> gradient = [
    background,
    background,
    fill,
    fill,
  ];
  const double fillPercent = 50; // fills 56.23% for container from bottom
  const double fillStop = (100 - fillPercent) / 100;
  const List<double> stops = [0.0, fillStop, fillStop, 1.0];
  return Column(
    children: [
      Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(2.0, 2.0), // shadow direction: bottom right
              ),
            ],
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradient,
              stops: stops,
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
            ),
          ),
          margin: const EdgeInsets.all(10),
          width: double.infinity,
          height: 150,
          child: Stack(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(
                              2.0, 2.0), // shadow direction: bottom right
                        ),
                      ],
                    ),
                    height: 130,
                    child: Image.network(
                        book.info.imageLinks["smallThumbnail"].toString()),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  // Texts
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // UEC607 & Digital communication text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: RichText(overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: (book.info.title +
                                                  ": " +
                                                  book.info.subtitle)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          )),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: FutureBuilder(future: _isCurrent(sale.isbn, sale.courses),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      bool current = snapshot.data as bool;
                                      return RichText(
                                        text: TextSpan(children: <TextSpan>[
                                          const TextSpan(
                                              text: "ISBN: ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12)),
                                          TextSpan(
                                              text: current
                                                  ? sale.isbn
                                                  : sale.isbn +
                                                  " OBS! Äldre upplaga",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: current ? Colors.black : Colors.red,
                                              )),
                                        ]),
                                      );
                                    } return Container();
                                  }
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                      const TextSpan(
                                          text: "Seller: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12)),
                                      TextSpan(
                                          text: seller.name +
                                              " " +
                                              seller.lastName,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 12)),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                      const TextSpan(
                                          text: "Condition: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12)),
                                      TextSpan(
                                          text: sale.condition,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 12)),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                              child: RichText(
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: sale.price.toString() + ":-",
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ]),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
    ],
  );
}

toastMessage(
    String toastMessage,
    int sec,
    ) {
  Fluttertoast.showToast(
      msg: toastMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: sec,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

Future<bool> _isCurrent(String isbn, List<String> courses) async {
  for (String shortCode in courses){
    Course course = await CourseHandler.getCourse(shortCode, FirebaseFirestore.instance);
    if(course.getCurrentIsbns().contains(isbn)){
      return true;
    }
  }
  return false;
}

_getInfo(Sale sale) async {
  Map<String, dynamic> infoList = {};
  infoList["book"] = await BookHandler.getBook(sale.isbn);
  infoList["seller"] =
      await UserHandler.getUser(sale.userID, FirebaseFirestore.instance);
  return infoList;
}
