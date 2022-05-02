import 'package:books_finder/books_finder.dart';
import 'dart:developer';

class BookHandler {
  static Future<Set<String>> getBookEditions(String name) async {
    List<Book> bookList = await getBookObjects(name);
    Set<String> result = {};

    for (Book book in bookList) {
      List<IndustryIdentifier> isbnList = List.from(book.info.industryIdentifiers);

      for (IndustryIdentifier number in isbnList){
        if (number.type == 'ISBN_13'){
          result.add(number.identifier);
        }
      }
    }

    return result;
  }

  static Future<String> getBookName(String isbn) async {
    final List<Book> books = await queryBooks(
      isbn,
      maxResults: 1,
      printType: PrintType.books,
      orderBy: OrderBy.relevance,
    );

    return (books[0].info.title + " " + books[0].info.subtitle).trim();
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

    books = List.from(books.where((book) => (book.info.title + " " + book.info.subtitle).toLowerCase().trim().contains(name.toLowerCase())));

    return books;
  }
}
