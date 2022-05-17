import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:test/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  final firestore = FakeFirebaseFirestore();

  //Populate mock firestore
  setUp(() async {
    //courses
    await firestore.collection('courses').doc('0').set({
      'name': 'Spelbaserat lärande',
      'code': 'IB530C',
      'shortCode': 'SL',
      'literature': {
        'The Gamification of Learning and instruction Game-based Methods and Strategies for Training and Education':
            ['9781118096345', '1118096347'],
      },
      'isbnNumbers': ['123123'],
    });

    await firestore.collection('courses').doc('1').set({
      'name': 'Programmering 1',
      'shortCode': 'PROG1',
      'code': 'IB133N',
      'literature': {
        'boken till prog1': ['isbn1', 'isbn2']
      },
      'isbnNumbers': ['123']
    });

    await firestore.collection('courses').doc('2').set({
      'name': 'PrototypkursN',
      'shortCode': 'PROTO',
      'code': 'IB711C',
      'literature': {
        'Prototyping:': ['123', '124']
      },
      'isbnNumbers': ['123']
    });
    //Users
    await firestore.collection('users').doc('boomerFc').set({
      'name': 'Zlatan',
      'lastName': 'Ibrahamovic',
      'courses': ['PROG1', 'PROTO', 'SL'],
    });

    //Sales
    await firestore.collection('sales').doc('0').set({
      'isbn': '1234',
      'userID': 'doav7858',
      'courses': ['PROTO'],
      'condition': 'good',
      'price': '290',
      'saleID': 'kl98',
    'description': "Great book"
    });

    await firestore.collection('sales').doc('1').set({
      'isbn': '1236',
      'userID': 'doav7858',
      'courses': ['PROG1', 'PROG2'],
      'condition': 'good',
      'price': 290,
      'saleID': 'kl98',
      'description': "Great book"
    });

    await firestore.collection('sales').doc('2').set({
      'isbn': '1236',
      'userID': 'piot2333',
      'courses': ['PROTO'],
      'condition': 'bad',
      'price': 220,
      'saleID': 'kl98',
      'description': "Great book"
    });

    await firestore.collection('sales').doc('3').set({
      'isbn': '1236',
      'userID': 'piot2333',
      'courses': ['PROG1', 'PROG2'],
      'condition': 'good',
      'price': 280,
      'saleID': 'kl98',
      'description': "Great book"
    });
  });

  group('Sale tests', () {
    test('get sales for user', () async {
      Sale sale1 = Sale.fromMap({
        'isbn': '1236',
        'userID': 'piot2333',
        'courses': ['PROG1', 'PROG2'],
        'condition': 'good',
        'price': 280,
        'saleID': 'kl98',
        'description': "Great book"
      });
      Sale sale2 = Sale.fromMap({
        'isbn': '1236',
        'userID': 'piot2333',
        'courses': ['PROTO'],
        'condition': 'bad',
        'price': 220,
        'saleID': 'kl98',
        'description': "Great book"
      });

      List<Sale> compare = [sale1, sale2];
      List<Sale> result =
          await SaleHandler.getSalesForUser("piot2333", firestore);
      for (Sale saleR in result) {
        assert(compare.contains(saleR));
      }
    });

    test('get sales for isbn', () async {
      Sale sale = Sale.fromMap({
        'isbn': '1236',
        'userID': 'doav7858',
        'courses': ['PROG1', 'PROG2'],
        'condition': 'good',
        'price': 290,
        'saleID': 'kl98',
        'description': "Great book"
      });

      List<Sale> result = await SaleHandler.getSalesForISBN("1236", "Price", firestore);
      expect(result[0], sale);
    });

    test('Is isbn in courses', () async {
      bool result = await CourseHandler.isIsbnInCourses("123123", firestore);

      expect(true, result);
    });

    

    test('Add sale', () async {
      Sale sale = Sale.fromMap({
        'isbn': '1111',
        'userID': 'doav7858',
        'courses': ['SL'],
        'condition': 'medium',
        'price': 210,
        'saleID': 'kl38',
        'description': "Great book"
      });

      SaleHandler.addSale(firestore, sale);

      QuerySnapshot query = await firestore
          .collection('sales')
          .where('isbn', isEqualTo: '1111')
          .get(); //.where('isbn', isEqualTo: '1111');

      bool result = false;
      for (DocumentSnapshot a in query.docs) {
        Sale random = Sale.fromMap(a.data() as Map<String, dynamic>);
        expect(random, sale);
      }
    });
  });
}
