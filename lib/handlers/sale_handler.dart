//import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/model/sale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleHandler {
  //get sales for user x
  static Future<List<Sale>> getSalesForUser(
      String userId, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('sales')
        .where('userID', isEqualTo: userId)
        .get();
    List<Sale> sales = [];
    for (DocumentSnapshot a in query.docs) {
      sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
    }
    return sales;
  }

  //get sales for isbn
  static Future<List<Sale>> getSalesForISBN(
      String isbn, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('sales')
        .where('isbn', isEqualTo: isbn)
        .get();
    List<Sale> sales = [];
    for (DocumentSnapshot a in query.docs) {
      sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
    }
    return sales;
  }

  //Checks if isbn is found in courses
  static Future<bool> isIsbnInCourses(
      String isbn, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('courses')
        .where('isbnNumbers', arrayContains: isbn)
        .get();

    if (query.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static getSaleId(FirebaseFirestore firestore) async {
    int saleId =
        (await firestore.collection('sales').doc("1").get()).data()!["counter"];
    firestore.collection('sales').doc("1").update({"counter": saleId + 1});
    return saleId;
  }

  //addsale
  static void addSale(FirebaseFirestore firestore, Sale sale) async {
    await firestore.collection('sales').doc(sale.saleID).set(sale.toMap());
  }

  //addsale

}
