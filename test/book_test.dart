import 'package:books_finder/books_finder.dart';
import 'package:test/test.dart';
import 'package:fook/handlers/book_handler.dart';

void main() {
  group('Book tests', () {
    test('Get books', () async {
      List<Book> lista = await BookHandler.getBooks('Jag är Zlatan');
      for (Book a in lista) {
        print(a.info);
      }
    });

    test('Get book name', () async {
      var result = await BookHandler.getBookName("9780226065663");
      expect("The craft of research", result);
    });
  });
}
