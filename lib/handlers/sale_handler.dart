//import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/model/sale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleHandler {
  //get sales for user x
  static Future<List<Sale>> getSalesForUser(
      String userId, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('sale')
        .where('userID', isEqualTo: userId)
        .get();
    List<Sale> sales = [];
    for (DocumentSnapshot a in query.docs) {
      sales.add(Sale.fromMap(a as Map<String, dynamic>));
    }
    return sales;
  }

  //get sales for isbn
  static Future<List<Sale>> getSalesForISBN(
      String isbn, FirebaseFirestore firestore) async {
    QuerySnapshot query =
        await firestore.collection('sale').where('isbn', isEqualTo: isbn).get();
    List<Sale> sales = [];
    for (DocumentSnapshot a in query.docs) {
      sales.add(Sale.fromMap(a as Map<String, dynamic>));
    }
    return sales;
  }

  //is there a corresponding course
  // vill kolla om isbn finns i befintliga isbn

  //static Future<boolean> isValid()

}
