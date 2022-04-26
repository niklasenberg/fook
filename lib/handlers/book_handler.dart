import 'package:books_finder/books_finder.dart';

class BookHandler {
  static Future<List<Book>> getBooks(String name) async {
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
