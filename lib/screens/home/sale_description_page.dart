import 'package:flutter/material.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/user.dart';
import 'package:fook/screens/fook_logo_appbar.dart';

import '../../handlers/user_handler.dart';
import '../../model/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      body: Column(
        children: [
          SaleCard(widget.sale, context)
        ],
      )
    );
  }
}

Widget SaleCard(Sale sale, context) {
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
  return FutureBuilder(
      future: _getInfo(sale),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> infoList = snapshot.data as Map<String, dynamic>;
          Book book = infoList["book"] as Book;
          User seller = infoList["seller"] as User;
          return Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset:
                            Offset(2.0, 2.0), // shadow direction: bottom right
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
                  margin: EdgeInsets.all(10),
                  width: double.infinity,
                  height: 150,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                ),
                              ],
                            ),
                            height: 130,
                            child: Image.network(book
                                .info.imageLinks["smallThumbnail"]
                                .toString()),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          // Texts
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // UEC607 & Digital communication text
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Flexible(
                                          child: RichText(
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
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(children: <TextSpan>[
                                              const TextSpan(
                                                  text: "ISBN: ",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                              TextSpan(
                                                  text: sale.isbn,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  )),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      padding:
                                          new EdgeInsets.fromLTRB(0, 0, 20, 0),
                                      child: RichText(
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  sale.price.toString() + ":-",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 20)),
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
              Stack(children: [
                Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
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
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ])
              ]),
            ],
          );
        }
        return Container(
            margin: EdgeInsets.all(10),
            width: double.infinity,
            height: 100,
            child: Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ))));
      });
}

_getInfo(Sale sale) async {
  Map<String, dynamic> infoList = {};
  infoList["book"] = await BookHandler.getBook(sale.isbn);
  infoList["seller"] = await UserHandler.getUser(sale.userID, FirebaseFirestore.instance);
  return infoList;
}
