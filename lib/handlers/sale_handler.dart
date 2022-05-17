//import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/model/sale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/course.dart';
import 'course_handler.dart';

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

  //get sales for course
  static Future<List<Sale>> getSalesForCourse(
      String shortCode, String order, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('sales')
        .where('courses', arrayContains: shortCode)
        .get();
    List<Sale> sales = [];
    for (DocumentSnapshot a in query.docs) {
      sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
    }

    if(order == "Price"){
      sales.sort((a, b) => a.price.compareTo(b.price));
    }else if (order == "Condition"){
      sales.sort((a, b) => b.condition.compareTo(a.condition));
    }
    return sales;
  }

  //get sales for course
  static Future<List<Sale>> getCurrentSalesForCourse(
      String shortCode, String order, FirebaseFirestore firestore) async {
    Course course = await CourseHandler.getCourse(shortCode, firestore);
    QuerySnapshot query = await firestore
        .collection('sales')
        .where('courses', arrayContains: shortCode)
        .get();
    List<Sale> sales = [];
    for (DocumentSnapshot a in query.docs) {
      Sale sale = Sale.fromMap(a.data() as Map<String, dynamic>);
      if(course.getCurrentIsbns().contains(sale.isbn)){
        sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
      }
    }

    if(order == "Price"){
      sales.sort((a, b) => a.price.compareTo(b.price));
    }else if (order == "Condition"){
      sales.sort((a, b) => b.condition.compareTo(a.condition));
    }
    return sales;
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
