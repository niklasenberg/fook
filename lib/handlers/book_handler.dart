import 'package:books_finder/books_finder.dart';

class BookHandler {
  static Future<Set<String>> getBookEditions(String name) async {
    List<Book> bookList = await getBookObjects(name);
    Set<String> result = {};

    for (Book book in bookList) {
      result.add(book.info.industryIdentifier as String);
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
    final List<Book> books = await queryBooks(
      name,
      maxResults: 3,
      printType: PrintType.books,
      orderBy: OrderBy.relevance,
    );

    books
        .sort((a, b) => b.info.publishedDate!.compareTo(a.info.publishedDate!));

    return books;
  }
}
