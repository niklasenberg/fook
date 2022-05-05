import 'package:cloud_firestore/cloud_firestore.dart';
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
        },
        'isbnNumbers': ['123123']
      });

      bool result = await SaleHandler.isIsbnInCourses("123123", firestore);

      expect(true, result);
    });
  });
}
