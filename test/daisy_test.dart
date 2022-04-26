import 'package:test/test.dart';
import 'package:fook/handlers/daisy_handler.dart';

void main() {
  group('Daisy tests', () {
    test('Successful fetch', () async {
      List<String> isbn = await DaisyHandler.getISBN('IB141N');
      expect(isbn.length, 2);
      expect(isbn[0], '9780226065663');
      expect(isbn[1], '9783319106311');
    });

    test('Unsuccessful fetch', () async {
      List<String> isbn = await DaisyHandler.getISBN('IB231N');
      expect(isbn.length, 0);
    });
  });
}
