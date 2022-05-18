//import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/course.dart';
import 'course_handler.dart';
import 'package:fook/model/book.dart';

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

  static Stream<List<Sale>> getSaleStream(
      String userId, FirebaseFirestore firestore) {
    var query = firestore
        .collection('sales')
        .where('userID', isEqualTo: userId);

    var stream = query.snapshots();

    return stream.map((event) => event.docs
        .map<Sale>((e) => Sale.fromMap(e.data()))
        .toList());
  }

  static Future<Sale> getSaleByID(
      String saleID, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('sales')
        .where('saleID', isEqualTo: saleID)
        .get();

    return Sale.fromMap(query.docs[0].data() as Map<String, dynamic>);
  }

  //get sales for isbn
  static Future<List<Sale>> getSalesForISBN(
      String isbn, String order, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('sales')
        .where('isbn', isEqualTo: isbn)
        .get();
    List<Sale> sales = [];
    for (DocumentSnapshot a in query.docs) {
      sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
    }

    if (order == "Price") {
      sales.sort((a, b) => a.price.compareTo(b.price));
    } else if (order == "Condition") {
      sales.sort((a, b) => b.condition.compareTo(a.condition));
    }
    return sales;
  }

  static Future<List<Sale>> getSalesForBook(
      Book book, String order, FirebaseFirestore firestore) async {
    Set<String> isbns = await BookHandler.getBookEditions(
        (book.info.title + " " + book.info.subtitle).trim());

    List<Sale> sales = [];
    for (String isbn in isbns) {
      QuerySnapshot query = await firestore
          .collection('sales')
          .where('isbn', isEqualTo: isbn)
          .get();

      for (DocumentSnapshot a in query.docs) {
        sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
      }
    }

    if (order == "Price") {
      sales.sort((a, b) => a.price.compareTo(b.price));
    } else if (order == "Condition") {
      sales.sort((a, b) => b.condition.compareTo(a.condition));
    }
    return sales;
  }

  static Future<List<Sale>> getCurrentSalesForBook(Book book, String shortCode,
      String order, FirebaseFirestore firestore) async {
    Course course = await CourseHandler.getCourse(shortCode, firestore);
    List<Sale> sales = [];
    for (IndustryIdentifier isbn in book.info.industryIdentifiers) {
      QuerySnapshot query = await firestore
          .collection('sales')
          .where('isbn', isEqualTo: isbn.identifier)
          .get();

      for (DocumentSnapshot a in query.docs) {
        if (course.getCurrentIsbns().contains(isbn.identifier)) {
          sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
        }
      }
    }

    if (order == "Price") {
      sales.sort((a, b) => a.price.compareTo(b.price));
    } else if (order == "Condition") {
      sales.sort((a, b) => b.condition.compareTo(a.condition));
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

    if (order == "Price") {
      sales.sort((a, b) => a.price.compareTo(b.price));
    } else if (order == "Condition") {
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
      if (course.getCurrentIsbns().contains(sale.isbn)) {
        sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
      }
    }

    if (order == "Price") {
      sales.sort((a, b) => a.price.compareTo(b.price));
    } else if (order == "Condition") {
      sales.sort((a, b) => b.condition.compareTo(a.condition));
    }
    return sales;
  }

  static Future<List<String>> getCoursesForIsbn(
      String isbn, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('courses')
        .where('isbnNumbers', arrayContains: isbn)
        .get();

    List<String> result = [];
    for (DocumentSnapshot d in query.docs) {
      result.add((d.data() as Map<String, dynamic>)['shortCode']);
    }
    return result;
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

  //updateSale
  static void updateSale(FirebaseFirestore firestore, String description,
      String condition, int price, String saleID) async {
    await firestore.collection('sales').doc(saleID).update({
      'description': description,
      'condition': condition,
      'price': price,
    });
  }

  //removeSale
  static void removeSale(FirebaseFirestore firestore, String saleID) async {
    await firestore.collection('sales').doc(saleID).delete();
  }
}
