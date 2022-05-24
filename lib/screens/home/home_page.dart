import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/model/book.dart';
import 'package:fook/screens/widgets/book_description_page.dart';
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
    return StreamBuilder(
        stream: UserHandler.getUserStream(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            fook.User thisUser = fook.User.fromMap(((snapshot.data) as DocumentSnapshot).data() as Map<String, dynamic>);
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                elevation: 1.5,
                centerTitle: false,
                title: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: "WELCOME ",
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
                                return SizedBox(
                                    height: 310,
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
                ),
              ),
            );
          }
        });
  }
}

Widget CourseCard(Course course, BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: 0.0,
    margin: EdgeInsets.zero,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          tileColor: Colors.white,
          title: Text(
            course.shortCode,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
            ),
          ),
          subtitle: Text(course.name,
              style: TextStyle(
                color: Colors.black,
              )),
          /*trailing: MaterialButton(
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
          ),*/
        ),

        // SizedBox(height: 200.0, child: BookCarousel(course, context)),
        Container(
          alignment: Alignment.center,
          height: 210,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.5, 0.5),
                  blurRadius: 1,
                ),
              ],
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
              image: DecorationImage(opacity: 0.1, scale: 4,
                image: AssetImage('lib/assets/s_logo_o.png'),
              )),
          child: SizedBox(height: 200, child: BookCarousel(course, context)),
        )
      ],
    ),
  );
}

Widget BookCarousel(Course course, BuildContext context) {
  return FutureBuilder(
      future: _getBooks(course),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Book> books = snapshot.data as List<Book>;
          if (books.isEmpty) {
            return const Center(
              child: Text("No literature listed for this course. \n"
                  "Maybe you should tell your teacher!"),
            );
          } else {
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (BuildContext context, int index) =>
                    BookCard(course.shortCode, books[index], context));
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

Widget BookCard(String shortCode, Book book, BuildContext context) {
  Color background = Colors.white;
  Color fill = Colors.white;
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
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      // margin: EdgeInsets.all(7),
      // color: Theme.of(context).colorScheme.background,
      child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookDescription(book, shortCode))),
          child: Container(
            height: 40,
            width: 150,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.0, 1.0), // shadow direction: bottom right
                  blurRadius: 2,
                  spreadRadius: 0.5,
                ),
              ],
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                colors: gradient,
                stops: stops,
                end: Alignment.bottomCenter,
                begin: Alignment.topCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  width: 70,
                  child: Container(
                    height: 50,
                    child: book.info.imageLinks["smallThumbnail"] != null ? Image.network(
                        book.info.imageLinks["smallThumbnail"].toString()) : Image.asset(
                      "lib/assets/placeholderthumbnail.png"),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          (book.info.subtitle.isNotEmpty ? (book.info.title + ": " + book.info.subtitle) : book.info.title),
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )));
}

Future<List<Book>> _getBooks(Course course) async {
  List<Book> result = [];
  for (String isbn in course.getCurrentIsbns()) {
    List<Book> books = await BookHandler.getBooks(isbn);

    if(books.isNotEmpty){
      result.add(books[0]);
    }

  }
  return result;
}

Future<List<Course>> _update() async {
  return await CourseHandler.updateUserCourses(
      FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);
}
