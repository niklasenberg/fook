import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:test/test.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/model/book.dart';

void main() {
  group('Sale tests', () {
    test('Is isbn in courses', () async {
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('courses').add({
        'name': 'Spelbaserat lärande',
        'code': 'IB530C',
        'shortCode': 'SL',
        'literature': {
          'The Gamification of Learning and instruction Game-based Methods and Strategies for Training and Education':
              ['9781118096345', '1118096347'],
          'isbnNumbers': '123123'
        }
      });

      bool result = await SaleHandler.isIsbnInCourses("123123", firestore);

      expect(true, result);
    });

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
        assert((b.info.title + " " + b.info.subtitle)
            .trim()
            .toLowerCase()
            .contains('the craft of research'));
      }
    });
  });
}
