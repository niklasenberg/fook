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

class AlgoliaApplication {
  static const Algolia algolia = Algolia.init(
    applicationId: '3KLN6AUQBU', //ApplicationID
    apiKey:
        '8a242909fc9a59d15c27ad46bafb9c5c', //search-only api key in flutter code
  );
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = ""; //TODO: Needed for realtime (?)
  final Algolia _algoliaApp = AlgoliaApplication.algolia;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("courses").query(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  //TODO: Uncomment for realtime search
  /*@override
  void initState() {
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.all(4),
                child: TextFormField(
                  controller: _searchController,
                  //TODO: Remove below for realtime search
                  onFieldSubmitted: (val) {
                    setState(() {
                      _searchTerm = _searchController.text;
                    });
                  },
                  decoration: InputDecoration(
                      suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ) : null,
                      prefixIcon: const Icon(Icons.search),
                      labelText: "ISBN, course name or course code."),
                )),
            Container(
              margin: const EdgeInsets.all(4),
              height: MediaQuery.of(context).size.height - 250,
              decoration: BoxDecoration(image: DecorationImage(opacity: 0.1, scale: 4, image: AssetImage("lib/assets/s_logo_o.png",)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.5, 0.5),
                      blurRadius: 1,
                    ),
                  ], borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xffeae6e6),
                  Color(0xfffafafa),
                  Color(0xfffaf4f4),
                  Color(0xffe5e3e3)
                ],
              ),),
              child: StreamBuilder<List<AlgoliaObjectSnapshot>>(
                stream: Stream.fromFuture(_operation(_searchController.text)),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || _searchController.text.isEmpty) {
                    return Center();
                  } else {
                    List<AlgoliaObjectSnapshot> searchHit = snapshot.data!;
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Container();
                      default:
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (searchHit.isNotEmpty) {
                          return ListView.builder(
                              itemCount: searchHit.length,
                              itemBuilder: (context, index) => _getBooks(
                                  searchHit[index].data["shortCode"], context));
                        } else {
                          return const Center(child: Text("No hits. :("));
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
      future: _getCurrentBooks(shortCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            width: double.infinity,
            height: 150,
            child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            ))),
          );
        } else if (snapshot.hasData) {
          List<Book> books = snapshot.data as List<Book>;
          return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: books.length,
              itemBuilder: (context, index) =>
                  BookCard(shortCode, books[index], context));
        }
        return SizedBox(
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
  return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BookDescription(book, shortCode))),
      child: Container(
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
          margin: EdgeInsets.all(5),
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
                    height: 130,
                    child: book.info.imageLinks["smallThumbnail"] != null ? Image.network(
                        book.info.imageLinks["smallThumbnail"].toString()) : Image.asset(
                        "lib/assets/placeholderthumbnail.png",
                      width: 70,
                      height: 3,
                    ),
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
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: book.info.subtitle.isNotEmpty
                                              ? (book.info.title +
                                                      ": " +
                                                      book.info.subtitle)
                                                  .toUpperCase()
                                              : book.info.title.toUpperCase(),
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
                                  child: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                      const TextSpan(
                                          text: "Course: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12)),
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
                            const SizedBox(
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
  Course course =
      await CourseHandler.getCourse(shortCode, FirebaseFirestore.instance);
  List<Book> books = [];
  for (String isbn in course.getCurrentIsbns()) {
    List<Book> result = await BookHandler.getBooks(isbn);
    if (result.isNotEmpty) {
      books.add(result[0]);
    }
  }
  return books;
}
