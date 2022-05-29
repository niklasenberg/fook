import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/model/book.dart';
import 'package:fook/model/sale.dart';
import 'package:test/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  final firestore = FakeFirebaseFirestore();

  //Populate mock firestore
  setUpAll(() async {
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

    //ID counter
    await firestore.collection('sales').doc('1').set({'counter': 1});

    await firestore.collection('sales').doc('10').set({
      'isbn': '1234',
      'userID': 'doav7858',
      'courses': ['PROTO'],
      'condition': 'good',
      'price': '290',
      'saleID': '10',
      'description': "Great book"
    });

    await firestore.collection('sales').doc('11').set({
      'isbn': '1236',
      'userID': 'doav7858',
      'courses': ['PROG1', 'PROG2'],
      'condition': 'good',
      'price': 290,
      'saleID': '11',
      'description': "Great book"
    });

    await firestore.collection('sales').doc('12').set({
      'isbn': '1236',
      'userID': 'piot2333',
      'courses': ['PROTO'],
      'condition': 'bad',
      'price': 220,
      'saleID': '12',
      'description': "Great book"
    });

    await firestore.collection('sales').doc('13').set({
      'isbn': '1236',
      'userID': 'piot2333',
      'courses': ['PROG1', 'PROG2'],
      'condition': 'good',
      'price': 280,
      'saleID': '13',
      'description': "Great book"
    });

    await firestore.collection('sales').doc('14').set({
      'isbn': '9781118096345',
      'userID': 'piot2333',
      'courses': ['PROG1', 'PROG2'],
      'condition': 'good',
      'price': 280,
      'saleID': '14',
      'description': "Great book"
    });

    await firestore.collection('sales').doc('15').set({
      'isbn': '1118096347',
      'userID': 'piot2333',
      'courses': ['PROG1', 'PROG2'],
      'condition': 'good',
      'price': 280,
      'saleID': '15',
      'description': "Great book"
    });
  });

  group('Sale tests', () {
    test('Get sales for user', () async {
      List<Sale> result =
          await SaleHandler.getSalesForUser("piot2333", firestore);
      expect(result.length, 4);
    });

    test('Get sale stream', () async {
      StreamBuilder(
          stream: SaleHandler.getSaleStream('piot2333', firestore),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              expect((snapshot.data as QuerySnapshot).docs.length, 2);
            }
            return Container();
          });
    });

    test('Get sale by ID', () async {
      //Correct
      Sale sale = await SaleHandler.getSaleByID('13', firestore);
      expect(sale.userID, 'piot2333');

      //Dummy object
      sale = await SaleHandler.getSaleByID('DOES NOT EXIST', firestore);
      expect(sale.userID, "userID");
    });

    test('Get sales for isbn', () async {
      Sale sale = Sale.fromMap({
        'isbn': '1236',
        'userID': 'doav7858',
        'courses': ['PROG1', 'PROG2'],
        'condition': 'good',
        'price': 290,
        'saleID': '11',
        'description': "Great book"
      });

      List<Sale> result =
          await SaleHandler.getSalesForISBN("1236", "Price", firestore);
      assert(result.contains(sale));
    });

    test('Get sales for book', () async {
      Book book = await BookHandler.getBook('9781118096345');
      List<Sale> sales =
          await SaleHandler.getSalesForBook(book, "Price", firestore);
      assert(sales.length == 2); //All books
      assert(sales[0].saleID == '14');
    });

    test('Get current sales for book', () async {
      Book book = await BookHandler.getBook('9781118096345');
      List<Sale> sales = await SaleHandler.getCurrentSalesForBook(
          book, 'SL', "Price", firestore);
      assert(sales.length == 1); //Only current
      assert(sales[0].saleID == '14');
    });

    test('Get sale ID', () async {
      //Fetch
      int currentId = await SaleHandler.getSaleId(firestore);
      assert(currentId == 1);

      //Check increment
      currentId = await SaleHandler.getSaleId(firestore);
      assert(currentId == 2);
    });

    test('Add sale', () async {
      Sale sale = Sale.fromMap({
        'isbn': '1111',
        'userID': 'doav7858',
        'courses': ['SL'],
        'condition': 'medium',
        'price': 210,
        'saleID': '16',
        'description': "Great book"
      });

      SaleHandler.addSale(sale, firestore);

      QuerySnapshot query = await firestore
          .collection('sales')
          .where('isbn', isEqualTo: '1111')
          .get();

      for (DocumentSnapshot a in query.docs) {
        Sale fetched = Sale.fromMap(a.data() as Map<String, dynamic>);
        expect(fetched, sale);
      }
    });

    test('Update sale', () async {
      Sale sale = await SaleHandler.getSaleByID('15', firestore);
      expect(sale.description, "Great book");
      expect(sale.price, 280);
      expect(sale.condition, 'good');

      SaleHandler.updateSale(
          "new description", "new condition", 80, "15", firestore);
      sale = await SaleHandler.getSaleByID('15', firestore);
      expect(sale.description, "new description");
      expect(sale.price, 80);
      expect(sale.condition, "new condition");
    });

    test('Remove sale', () async {
      Sale sale = Sale.fromMap({
        'isbn': '1111',
        'userID': 'doav7858',
        'courses': ['SL'],
        'condition': 'medium',
        'price': 210,
        'saleID': '17',
        'description': "Great book"
      });
      SaleHandler.addSale(sale, firestore);

      SaleHandler.removeSale('17', firestore);
      sale = await SaleHandler.getSaleByID('17', firestore);
      expect(sale.userID, "userID");
    });
  });
}
