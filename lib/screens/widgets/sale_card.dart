import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/book.dart';
import '../../model/course.dart';
import '../../model/sale.dart';
import '../../model/user.dart' as fook;
import '../../handlers/course_handler.dart';

///Card displaying a Sale object, is used almost everywhere
Widget saleCard(String myId, String sellerId, Sale sale, fook.User seller,
    Book book, context) {
  return Column(
    children: [
      Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(1.0, 1.0),
                blurRadius: 2,
                spreadRadius: 0.5,
              ),
            ],
            border: Border.all(
                color: myId == sellerId
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                width: 4),
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.all(10),
          width: double.infinity,
          height: 160,
          child: Stack(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    height: 130,
                    child: book.info.imageLinks["smallThumbnail"] != null
                        ? Image.network(
                            book.info.imageLinks["smallThumbnail"].toString())
                        : Image.asset("lib/assets/placeholderthumbnail.png"),
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
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
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
                                    child: FutureBuilder(
                                        future:
                                            _isCurrent(sale.isbn, sale.courses),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            bool current =
                                                snapshot.data as bool;
                                            return RichText(
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                                const TextSpan(
                                                    text: "ISBN: ",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12)),
                                                TextSpan(
                                                    text: current
                                                        ? sale.isbn
                                                        : sale.isbn +
                                                            " NOTE: Older edition!",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: current
                                                          ? Colors.black
                                                          : Colors.red,
                                                    )),
                                              ]),
                                            );
                                          }
                                          return Container();
                                        })),
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
                                          text: myId == sellerId
                                              ? "Me"
                                              : seller.name +
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

///Helper method that determines whether Sale object is current in any course
Future<bool> _isCurrent(String isbn, List<String> courses) async {
  for (String shortCode in courses) {
    Course course =
        await CourseHandler.getCourse(shortCode, FirebaseFirestore.instance);
    if (course.getCurrentIsbns().contains(isbn)) {
      return true;
    }
  }
  return false;
}
