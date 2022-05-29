import 'package:test/test.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/model/book.dart';

void main() {
  group('Book tests', () {
    test('Get book editions', () async {
      Set<String> result =
          await BookHandler.getBookEditions('The craft of research');
      assert(result.contains('9780226062648'));
      assert(result.contains('9780226065830'));
      assert(result.contains('9780226239873'));
    });

    test('Get correct book', () async {
      Book book = await BookHandler.getBook('9781408855652');
      String bookOne = (book.info.title + " " + book.info.subtitle).trim();
      expect(bookOne.toLowerCase(), "harry potter and the philosopher's stone");

      book = await BookHandler.getBook('9789100126537');
      String bookTwo = (book.info.title + " " + book.info.subtitle).trim();
      expect(bookTwo.toLowerCase(), "jag är zlatan ibrahimovic min historia");
    });

    test('Get nullable book', () async {
      List<Book> books = await BookHandler.getNullableBook('not a valid isbn');
      assert(books.isEmpty);
    });

    test('Get multiple books', () async {
      List<Book> result = await BookHandler.getBooks('The craft of research');
      for (Book b in result) {
        //Ensure all fetched books have the correct title
        assert((b.info.title + " " + b.info.subtitle)
            .trim()
            .toLowerCase()
            .contains('the craft of research'));
      }
    });
  });
}
