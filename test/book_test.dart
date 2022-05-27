import 'package:test/test.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/model/book.dart';

void main() {
  group('Book tests', () {
    test('Get book name', () async {
      var result = await BookHandler.getBookName("9780226065663");
      expect("The craft of research", result);
    });

    test('Get book editions', () async {
      Set<String> result =
          await BookHandler.getBookEditions('The craft of research');
      assert(result.contains('9780226062648'));
      assert(result.contains('9780226065830'));
      assert(result.contains('9780226239873'));
    });

    test('Get book objects', () async {
      List<Book> result =
          await BookHandler.getBookObjects('The craft of research');
      for (Book b in result) {
        assert((b.info.title + " " + b.info.subtitle).trim().toLowerCase().contains('the craft of research'));
      }
    });

    test('Get correct books', () async {
      String bookOne = await BookHandler.getBookName('9781408855652');
      expect(bookOne.toLowerCase(), "harry potter and the philosopher's stone");

      String bookTwo = await BookHandler.getBookName('9789100126537');
      expect(bookTwo.toLowerCase(), "jag är zlatan ibrahimovic min historia");
    });
  });
}
