import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';

import '../../model/book.dart';
import '../../model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/book_description_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class AlgoliaApplication{
  static final Algolia algolia = Algolia.init(
    applicationId: '3KLN6AUQBU', //ApplicationID
    apiKey: '8a242909fc9a59d15c27ad46bafb9c5c', //search-only api key in flutter code
  );
}

class _SearchPageState extends State<SearchPage> {
  late String _searchTerm;
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  TextEditingController input = TextEditingController();

  @override
  void initState(){
    super.initState();
    _searchTerm = input.text;
  }

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("courses").query(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(4),
                margin: EdgeInsets.all(4),
                child: TextField(
                  controller: input,
                  onChanged: (val) {
                    setState(() {
                      _searchTerm = val;
                    });
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: "Enter course name or code."),
                )),
            Container(
              padding: EdgeInsets.all(4),
              margin: EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height * 0.63,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                ),
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: -2.0,
                  blurRadius: 12.0,
                ),
              ], borderRadius: BorderRadius.all(Radius.circular(8))),
              child: StreamBuilder<List<AlgoliaObjectSnapshot>>(
                stream: Stream.fromFuture(_operation(_searchTerm)),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || _searchTerm.isEmpty)
                    return Center(child: Text(
                      "Enter your query.",
                      style: TextStyle(color: Colors.black),
                    ));
                  else {
                    List<AlgoliaObjectSnapshot> searchHit = snapshot.data!;
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Container();
                      default:
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}');
                        else if (searchHit.isNotEmpty) {
                          return ListView.builder(itemCount: searchHit.length, itemBuilder: (context, index) => _getBooks(searchHit[index].data["shortCode"], context));
                        } else {
                          return Center(child: Text("No hits. :("));
                        }
                    }
                  }
                },
              ),
            )
          ],
        )));
  }
}

_getBooks(String shortCode, BuildContext context) {
  return FutureBuilder(
      future: _getCurrentBooks(shortCode), builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return Container(
        width: double.infinity,
        height: 150,
        child: Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ))),
      );
    }
    else if (snapshot.hasData){
      List<Book> books = snapshot.data as List<Book>;
      return ListView.builder(
          shrinkWrap: true,
          itemCount: books.length,
          itemBuilder: (context, index) => BookCard(shortCode, books[index], context));
    }
    return Container(
      width: double.infinity,
      height: 150,
      child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ))),
    );
  });
}

Widget BookCard(String shortCode, Book book, context) {
  Color background = Colors.grey.shade300;
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
  return GestureDetector(onTap: () =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BookDescription(book, shortCode))),
      child: Container(
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
      margin: EdgeInsets.all(5),
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
                      offset:
                      Offset(2.0, 2.0), // shadow direction: bottom right
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: RichText(
                                text: TextSpan(children: <TextSpan>[
                                  const TextSpan(
                                      text: "Course: ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12)),
                                  TextSpan(
                                      text: shortCode,
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      )));
}

Future<List<Book>> _getCurrentBooks(String shortCode) async {
  Course course = await CourseHandler.getCourse(shortCode, FirebaseFirestore.instance);
  List<Book> books = [];
  for (String isbn in course.getCurrentIsbns()){
    books.add(await BookHandler.getBook(isbn));
  }
  return books;
}