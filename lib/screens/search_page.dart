import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/course_handler.dart';
import '../model/book.dart';
import '../model/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import 'book_description_page.dart';

///Page for searching by course name, code or ISBN numbers
///Uses externally established search index via
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

///Algolia app settings
class AlgoliaApplication {
  static const Algolia algolia = Algolia.init(
    applicationId: '3KLN6AUQBU', //ApplicationID
    apiKey: '8a242909fc9a59d15c27ad46bafb9c5c', //search-only api key
  );
}

class _SearchPageState extends State<SearchPage> {
  //Controller that is listened to
  final TextEditingController _searchController = TextEditingController();

  //Term feeded to search operation
  String _searchTerm = "";

  //Needed for Algolia search
  final Algolia _algoliaApp = AlgoliaApplication.algolia;

  @override
  void initState() {
    //Enables realtime search by listening to controller
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
    super.initState();
  }

  //Needed when using listener
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: Column(
          children: [
            _searchField(),
            _bookList(),
          ],
        )));
  }

  ///List presenting search results
  Widget _bookList() {
    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height - 250,
      decoration: BoxDecoration(
        image: const DecorationImage(
            opacity: 0.1,
            scale: 4,
            image: AssetImage(
              "lib/assets/s_logo_o.png",
            )),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.5, 0.5),
            blurRadius: 1,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: CustomColors.fookGradient,
        ),
      ),
      child: StreamBuilder<List<AlgoliaObjectSnapshot>>(
        stream: Stream.fromFuture(_operation(_searchTerm)),
        builder: (context, snapshot) {
          if (!snapshot.hasData || _searchTerm.isEmpty) {
            return const Center();
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
    );
  }

  ///Textfield for entering query
  Widget _searchField() {
    return Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.all(4),
        child: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              prefixIcon: const Icon(Icons.search),
              labelText: "ISBN, course name or course code."),
        ));
  }

  ///Card displaying a book object
  ///Sends user to [BookDescription]
  Widget _bookCard(String shortCode, Book book, context) {
    return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BookDescription(book, shortCode))),
        child: Container(
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
            margin: const EdgeInsets.all(5),
            width: double.infinity,
            height: 150,
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
                          : Image.asset(
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

  ///Helper method for performing queries against Algola index
  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("courses").query(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  ///Helper method to display query results
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
                    _bookCard(shortCode, books[index], context));
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

  ///Helper method to fetch book for query results
  _getCurrentBooks(String shortCode) async {
    Course course =
        await CourseHandler.getCourse(shortCode, FirebaseFirestore.instance);
    List<Book> books = [];
    for (String isbn in course.getCurrentIsbns()) {
      List<Book> result = await BookHandler.getNullableBook(isbn);
      if (result.isNotEmpty) {
        books.add(result[0]);
      }
    }
    return books;
  }
}
