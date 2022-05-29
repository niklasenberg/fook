import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart' as fook;
import 'package:fook/model/book.dart';
import 'package:fook/screens/book_description_page.dart';
import 'package:fook/screens/widgets/rounded_app_bar.dart';
import '../handlers/user_handler.dart';
import '../model/book.dart';

///Page presenting the user with its enrolled courses
///and corresponding literature
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
        //Realtime updates of changes to users information
        stream: UserHandler.getUserStream(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            fook.User thisUser = fook.User.fromMap(
                ((snapshot.data) as DocumentSnapshot).data()
                    as Map<String, dynamic>);
            return Scaffold(
              appBar: RoundedAppBar(
                  "WELCOME " + thisUser.name.toUpperCase(),
                  Theme.of(context).highlightColor,
                  "Here are your current courses"),
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
                                    child:
                                        _courseCard(courses[index], context));
                              }),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Delivery error: ${snapshot.error.toString()}',
                          style: const TextStyle(color: Colors.black),
                        );
                      } else {
                        return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: const Color.fromARGB(255, 228, 227, 227),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/fook_r_24fps_appBack.gif',
                                  scale: 4,
                                ),
                                const Text("Updating...")
                              ],
                            ));
                      }
                    }),
              ),
              backgroundColor: Theme.of(context).backgroundColor,
            );
          } else {
            return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color.fromARGB(255, 228, 227, 227),
                child: Image.asset(
                  'lib/assets/fook_r_24fps_appBack.gif',
                  scale: 4,
                ));
          }
        });
  }
}

///Each courses representative card, containing a [_bookCarousel]
Widget _courseCard(Course course, BuildContext context) {
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
              color: Theme.of(context).highlightColor,
              fontSize: 20,
            ),
          ),
          subtitle: Text(course.name,
              style: const TextStyle(
                color: Colors.black,
              )),
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
              image: DecorationImage(
                opacity: 0.1,
                scale: 4,
                image: AssetImage('lib/assets/s_logo_o.png'),
              )),
          child: SizedBox(height: 200, child: _bookCarousel(course, context)),
        )
      ],
    ),
  );
}

///Each courses list/carousel of books, contained within a [_courseCard]
Widget _bookCarousel(Course course, BuildContext context) {
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
                    _bookCard(course.shortCode, books[index], context));
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

///Visual representation of a specific book, displayed in a [_bookCarousel]
Widget _bookCard(String shortCode, Book book, BuildContext context) {
  return Container(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookDescription(book, shortCode))),
          child: Container(
            height: 40,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.0, 1.0), // shadow direction: bottom right
                  blurRadius: 2,
                  spreadRadius: 0.5,
                ),
              ],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  width: 70,
                  child: SizedBox(
                    height: 50,
                    child: book.info.imageLinks["smallThumbnail"] != null
                        ? Image.network(
                            book.info.imageLinks["smallThumbnail"].toString())
                        : Image.asset("lib/assets/placeholderthumbnail.png"),
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
                          (book.info.subtitle.isNotEmpty
                              ? (book.info.title + ": " + book.info.subtitle)
                              : book.info.title),
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

///Helper method for fetching the Book objects for a specific course
Future<List<Book>> _getBooks(Course course) async {
  List<Book> result = [];
  for (String isbn in course.getCurrentIsbns()) {
    List<Book> books = await BookHandler.getNullableBook(isbn);

    if (books.isNotEmpty) {
      result.add(books[0]);
    }
  }
  return result;
}

///Helper method for fetching AND updating user's courses
Future<List<Course>> _update() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  return await CourseHandler.updateCourses(
      (await CourseHandler.getUserCourses(
          FirebaseAuth.instance.currentUser!.uid, firestore)),
      firestore);
}
