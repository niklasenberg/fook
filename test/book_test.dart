import 'package:books_finder/books_finder.dart';
import 'package:test/test.dart';
import 'package:fook/handlers/book_handler.dart';

void main() {
  group('Book tests', () {
    test('Successful fetch', () async {
      List<Book> lista = await BookHandler.getBooks('Jag är Zlatan');
      for (Book a in lista) {
        print(a.info);
      }

      // expect(isbn.length, 2);
      // expect(isbn[0], '9780226065663');
      // expect(isbn[1], '9783319106311');
    });
/*
    test('Unsuccessful fetch', () async {
      List<Book> isbn = await BookHandler.getBooks('twilight');
      expect(isbn.length, 0);
    });*/
  });
}
