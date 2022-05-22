import 'dart:convert';
import 'package:fook/model/book.dart';
import 'package:http/http.dart' as http;

class BookHandler {
  static Future<Set<String>> getBookEditions(String name) async {
    List<Book> bookList = await getBookObjects(name);
    Set<String> result = {};

    for (Book book in bookList) {
      List<IndustryIdentifier> isbnList =
          List.from(book.info.industryIdentifiers);

      for (IndustryIdentifier number in isbnList) {
        result.add(number.identifier);
      }
    }

    return result;
  }

  static Future<String> getBookName(String isbn) async {
    final List<Book> books = await queryBooks(
      isbn,
      queryType: QueryType.isbn,
      maxResults: 1,
      printType: PrintType.books,
      orderBy: OrderBy.relevance,
    );

    return (books[0].info.title + " " + books[0].info.subtitle).trim();
  }

  static Future<Book> getBook(String isbn) async {
    final List<Book> books = await queryBooks(
      isbn,
      queryType: QueryType.isbn,
      maxResults: 1,
      printType: PrintType.books,
      orderBy: OrderBy.relevance,
    );

    return (books[0]);
  }

  static String getIsbn(Book book){
    return book.info.industryIdentifiers.first.toString();

  }

  static Future<List<Book>> getBookObjects(String name) async {
    List<Book> books = await queryBooks(
      name,
      maxResults: 10,
      printType: PrintType.books,
      orderBy: OrderBy.relevance,
    );

    books
        .sort((a, b) => b.info.publishedDate!.compareTo(a.info.publishedDate!));

    books = List.from(books.where((book) =>
        (book.info.title + " " + book.info.subtitle)
            .toLowerCase()
            .trim()
            .contains(name.toLowerCase())));

    return books;
  }


}

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
  assert(query.isNotEmpty);

  var url = 'https://www.googleapis.com/books/v1/volumes?q=';

  if (queryType != null) url += queryType.name + ':';

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
