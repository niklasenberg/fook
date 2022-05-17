import 'package:flutter/material.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/user.dart';

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
                User seller = infoList["seller"] as User;
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
                              Padding(padding: EdgeInsets.all(4)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
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
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      RichText(
                                        text: TextSpan(
                                            text: "Sellers description:",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                ]),
                                Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey.shade300,
                                    ),
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    height: 100,
                                    child: Column(
                                      children: [
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(
                                                  text: widget.sale.description,
                                                  style: TextStyle(
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
                    Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        onPressed: () {},
                        child: const Text('Send message to seller'),
                        textColor: Colors.white,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  ],
                );
              }
              return Container(
                  margin: EdgeInsets.all(10),
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

Widget SaleCard(Sale sale, User seller, Book book, context) {
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
            boxShadow: [
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
                          offset: Offset(
                              2.0, 2.0), // shadow direction: bottom right
                        ),
                      ],
                    ),
                    height: 130,
                    child: Image.network(
                        book.info.imageLinks["smallThumbnail"].toString()),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
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
                            SizedBox(
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
                            SizedBox(
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
                            SizedBox(
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
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              padding: new EdgeInsets.fromLTRB(0, 0, 20, 0),
                              child: RichText(
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: sale.price.toString() + ":-",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 20,
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
