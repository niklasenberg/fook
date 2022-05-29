import 'dart:convert';
import 'package:fook/model/book.dart';
import 'package:http/http.dart' as http;

/// Handler class that fetches data from Google Books API
class BookHandler {
  /// Given a name, returns a set of known ISBNs for that book
  static Future<Set<String>> getBookEditions(String name) async {
    //Fetch list of books with same name
    List<Book> bookList = await getBooks(name);

    //For each fetched book, add their corresponding ISBNs
    Set<String> result = {};
    for (Book book in bookList) {
      List<IndustryIdentifier> isbnList =
          List.from(book.info.industryIdentifiers);

      //Each book can contains several ISBNs
      for (IndustryIdentifier number in isbnList) {
        result.add(number.identifier);
      }
    }

    return result;
  }

  ///Given an ISBN number, returns a Book object
  ///Does not accept bad isbn numbers
  static Future<Book> getBook(String isbn) async {
    final List<Book> books = await queryBooks(
      isbn,
      queryType: QueryType.isbn,
      maxResults: 1,
      printType: PrintType.books,
      orderBy: OrderBy.relevance,
    );

    return books[0];
  }

  ///Given an ISBN number, returns a Book object
  ///Accepts bad isbn numbers
  static Future<List<Book>> getNullableBook(String isbn) async {
    final List<Book> books = await queryBooks(
      isbn,
      queryType: QueryType.isbn,
      maxResults: 1,
      printType: PrintType.books,
      orderBy: OrderBy.relevance,
    );

    List<Book> result = [];
    if (books.isNotEmpty) {
      result.add(books[0]);
    }

    return result;
  }

  ///Given a name, returns a list of book objects with matching title and subtitle
  static Future<List<Book>> getBooks(String name) async {
    if (name == "Unknown") {
      return [];
    }

    //Fetch 10 books
    List<Book> books = await queryBooks(
      name,
      maxResults: 10,
      printType: PrintType.books,
      orderBy: OrderBy.relevance,
    );

    //Sort list of books by year published
    books
        .sort((a, b) => b.info.publishedDate!.compareTo(a.info.publishedDate!));

    //Filter to ensure correct title + subtitle in fetched books
    books = List.from(books.where((book) =>
        (book.info.title + " " + book.info.subtitle)
            .toLowerCase()
            .trim()
            .contains(name.toLowerCase())));

    return books;
  }
}

/// Method for querying against Google Books API
/// ///Initially used via package [https://pub.dev/packages/books_finder], later
///adopted and modified.
Future<List<Book>> queryBooks(
  String query, {
  QueryType? queryType,
  String? langRestrict,
  int maxResults = 10,
  OrderBy? orderBy,
  PrintType? printType = PrintType.all,
  int startIndex = 0,
  bool reschemeImageLinks = false,
}) async {
  //Makes sure query isnt empty
  assert(query.isNotEmpty);

  //Base URL
  var url = 'https://www.googleapis.com/books/v1/volumes?q=';

  //If the queryType is undefined, default to "name"
  if (queryType != null) url += queryType.name + ':';

  //Append different string to query url depending on parameters
  var q = '$url'
      '${query.trim().replaceAll(' ', '+')}'
      '&maxResults=$maxResults'
      '&startIndex=$startIndex';

  if (langRestrict != null) q += '&langRestrict=$langRestrict';
  if (orderBy != null) {
    q += '&orderBy=${orderBy.toString().replaceAll('OrderBy.', '')}';
  }
  if (printType != null) {
    q += '&printType=${printType.toString().replaceAll('PrintType.', '')}';
  }
  final result = await http.get(Uri.parse(q));
  if (result.statusCode == 200) {
    final books = <Book>[];
    final list = (jsonDecode(result.body))['items'] as List<dynamic>?;
    if (list == null) return [];
    for (final e in list) {
      //Create Book objects from JSON Response
      books.add(Book.fromJson(e, reschemeImageLinks: reschemeImageLinks));
    }
    return books;
  } else {
    throw (result.body);
  }
}

/// Special keywords you can specify in the search terms to search by particular fields
enum QueryType {
  /// Returns results where the text following this keyword is found in the title.
  intitle,

  /// Returns results where the text following this keyword is found in the author.
  inauthor,

  /// Returns results where the text following this keyword is found in the publisher.
  inpublisher,

  /// Returns results where the text following this keyword is listed in the category list of the volume.
  subject,

  /// Returns results where the text following this keyword is the ISBN number.
  isbn,

  /// Returns results where the text following this keyword is the Library of Congress Control Number.
  lccn,

  /// Returns results where the text following this keyword is the Online Computer Library Center number.
  oclc,
}

/// Order the query by `newest` or `relevance`
enum OrderBy {
  /// Returns search results in order of the newest published date
  /// to the oldest.
  newest,

  /// Returns search results in order of the most relevant to least
  /// (this is the default).
  relevance,
}

enum PrintType {
  /// Return all volume content types (no restriction). This is the default.
  all,

  /// Return only books.
  books,

  /// Return only magazines.
  magazines,
}
