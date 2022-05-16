import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/book.dart';
import 'package:fook/screens/home/all_sales_page.dart';
import 'package:fook/screens/home/sale_description_page.dart';
import '../../handlers/user_handler.dart';
import '../../model/book.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: UserHandler.getUser(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            fook.User thisUser = snapshot.data as fook.User;
            return Scaffold(
              appBar: AppBar(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                centerTitle: false,
                title: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: "Welcome ",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20)),
                    TextSpan(
                        text: thisUser.name,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
                bottom: PreferredSize(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 0, 5),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Your current courses",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  preferredSize: const Size.fromHeight(1),
                ),
                backgroundColor: Colors.white,
              ),
              body: Center(
                child: FutureBuilder(
                    future: _update(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Course> courses = snapshot.data as List<Course>;
                        return Center(
                          child: ListView.builder(
                              itemCount: courses.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    height: 400,
                                    child: CourseCard(courses[index], context));
                              }),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Delivery error: ${snapshot.error.toString()}',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
              ),
              backgroundColor: Theme.of(context).backgroundColor,
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            )));
          }
        });
  }
}

Widget CourseCard(Course course, BuildContext context) {
  return Card(
    elevation: 4.0,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          title: Text(
            course.shortCode,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          subtitle: Text(course.name),
          trailing: MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AllSalesPage(course)));
            },
            child: const Text('Show all'),
            textColor: Theme.of(context).colorScheme.background,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 300.0, child: SaleCarousel(course, context)),
      ],
    ),
  );
}

Widget SaleCarousel(Course course, BuildContext context) {
  return FutureBuilder(
      future: _getSales(course),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Sale> sales = snapshot.data as List<Sale>;
          if (sales.isEmpty) {
            return const Center(
              child: Text("No current literature available.\n"
                  "Try pressing the \"Show all\" button"),
            );
          } else {
            //TODO: Ska vi ha listview eller Carousel?
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sales.length,
                itemBuilder: (BuildContext context, int index) =>
                    SaleCard(sales[index], context));
            /*return CarouselSlider(
            options: CarouselOptions(enableInfiniteScroll: true),
    items: sales.map((sale) => SaleCard(sale, context)).toList(),
        );*/
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
            Theme.of(context).colorScheme.primary,
          )));
        }
      });
}

Widget SaleCard(Sale sale, BuildContext context) {
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
  return Container(
      margin: EdgeInsets.all(2),
      color: Theme.of(context).colorScheme.background,
      child: FutureBuilder(
          future: _getInfo(sale),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> infoList =
                  snapshot.data as Map<String, dynamic>;
              Book book = infoList["book"] as Book;
              fook.User seller = infoList["seller"] as fook.User;
              return InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SaleDescription(sale))),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.grey,
                          offset: Offset(
                              2.0, 2.0), // shadow direction: bottom right
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
                    height: 100,
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 10),
                            SizedBox(
                              height: 100,
                              width: 70,
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(2.0,
                                          2.0), // shadow direction: bottom right
                                    ),
                                  ],
                                ),
                                height: 50,
                                child: Image.network(book
                                    .info.imageLinks["smallThumbnail"]
                                    .toString()),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    (book.info.title +
                                            ": " +
                                            book.info.subtitle)
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                          ],
                        ),
                      ],
                    ),
                  ));
            } else {
              return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      const BoxShadow(
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
                  height: 100,
                  width: 150,
                  child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary,
                  ))));
            }
          }));
}

Future<List<Course>> _update() async {
  return await CourseHandler.updateUserCourses(
      FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);
}

Future<List<Sale>> _getSales(Course course) async {
  List<Sale> result = [];
  for (String isbn in course.getCurrentIsbns()) {
    result.addAll(
        await SaleHandler.getSalesForISBN(isbn, FirebaseFirestore.instance));
  }
  return result;
}

_getInfo(Sale sale) async {
  Map<String, dynamic> infoList = {};
  infoList["book"] = await BookHandler.getBook(sale.isbn);
  infoList["seller"] =
      await UserHandler.getUser(sale.userID, FirebaseFirestore.instance);
  return infoList;
}
