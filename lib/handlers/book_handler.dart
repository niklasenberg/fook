import 'package:books_finder/books_finder.dart';
import 'dart:developer';

class BookHandler {
  static Future<Set<String>> getBookEditions(String name) async {
    List<Book> bookList = await getBookObjects(name);
    Set<String> result = {};

    for (Book book in bookList) {
      List<IndustryIdentifier> isbnList = List.from(book.info.industryIdentifier);

      for (IndustryIdentifier number in isbnList){
        if (number.toString().contains('ISBN_13')){
          result.add(number.toString().substring(8, number.toString().length));
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

    return books[0].info.title;
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

    books = List.from(books.where((book) => book.info.title.toLowerCase().contains(name.toLowerCase())));

    return books;
  }
}
