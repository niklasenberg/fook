import 'package:fook/handlers/book_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/course.dart';
import 'course_handler.dart';
import 'package:fook/model/book.dart';

///Handler class which fetches/writes data concerning sale objects
class SaleHandler {
  ///Given a user Id, returns a list of that users Sale objects
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

  ///Given a user Id, returns a stream of that users Sale objects
  ///This to enable realtime updates of Sale objects
  static Stream<List<Sale>> getSaleStream(
      String userId, FirebaseFirestore firestore) {
    return firestore
        .collection('sales')
        .where('userID', isEqualTo: userId)
        .snapshots() //Establish stream
        .map((event) => event.docs
            .map<Sale>((e) => Sale.fromMap(e.data()))
            .toList()); //Construct objects
  }

  ///Given a Sale id, return either the corresponding Sale object or a dummy object.
  static Future<Sale> getSaleByID(
      String saleID, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('sales')
        .where('saleID', isEqualTo: saleID)
        .get();

    if (query.docs.isNotEmpty) {
      //Construct object
      return Sale.fromMap(query.docs[0].data() as Map<String, dynamic>);
    } else {
      //Dummy object
      return Sale(
          isbn: '0',
          userID: 'userID',
          courses: [],
          condition: '1/5',
          price: 0,
          saleID: 'saleID',
          description: 'removed');
    }
  }

  ///Given an ISBN number, and a sort parameter,
  ///return a sorted list of corresponding Sale objects
  static Future<List<Sale>> getSalesForISBN(
      String isbn, String order, FirebaseFirestore firestore) async {
    QuerySnapshot query = await firestore
        .collection('sales')
        .where('isbn', isEqualTo: isbn)
        .get();
    List<Sale> sales = [];

    //Construct sale objects
    for (DocumentSnapshot a in query.docs) {
      sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
    }

    //Sort depending on parameter
    if (order == "Price") {
      sales.sort((a, b) => a.price.compareTo(b.price));
    } else if (order == "Condition") {
      sales.sort((a, b) => b.condition.compareTo(a.condition));
    }
    return sales;
  }

  ///Given a book object, and a sort parameter,
  ///return a sorted list of ALL KNOWN Sale objects corresponding to the books ISBNs.
  static Future<List<Sale>> getSalesForBook(
      Book book, String order, FirebaseFirestore firestore) async {
    //Fetch all known editions of the book (older AND current)
    Set<String> isbns = await BookHandler.getBookEditions(
        (book.info.title + " " + book.info.subtitle).trim());
    for (IndustryIdentifier isbn in book.info.industryIdentifiers) {
      isbns.add(isbn.identifier);
    }

    //For each editions, fetch corresponding Sale objects from the database
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

    //Sort the result
    if (order == "Price") {
      sales.sort((a, b) => a.price.compareTo(b.price));
    } else if (order == "Condition") {
      sales.sort((a, b) => b.condition.compareTo(a.condition));
    }
    return sales;
  }

  ///Given a book object, and a sort parameter, and a course shortCode
  ///return a sorted list of CURRENT Sale objects corresponding to the books ISBNs.
  static Future<List<Sale>> getCurrentSalesForBook(Book book, String shortCode,
      String order, FirebaseFirestore firestore) async {
    //Fetch Course object from shortCode
    Course course = await CourseHandler.getCourse(shortCode, firestore);

    List<Sale> sales = [];
    for (IndustryIdentifier isbn in book.info.industryIdentifiers) {
      //Query sales with corresponding ISBN
      QuerySnapshot query = await firestore
          .collection('sales')
          .where('isbn', isEqualTo: isbn.identifier)
          .get();

      for (DocumentSnapshot a in query.docs) {
        //Check whether ISBN is current, if so add Sale object to result
        if (course.getCurrentIsbns().contains(isbn.identifier)) {
          sales.add(Sale.fromMap(a.data() as Map<String, dynamic>));
        }
      }
    }

    //Sort result
    if (order == "Price") {
      sales.sort((a, b) => a.price.compareTo(b.price));
    } else if (order == "Condition") {
      sales.sort((a, b) => b.condition.compareTo(a.condition));
    }

    return sales;
  }

  ///Updates and returns a counter to be used for sale Ids
  static getSaleId(FirebaseFirestore firestore) async {
    int saleId =
        (await firestore.collection('sales').doc("1").get()).data()!["counter"];
    firestore.collection('sales').doc("1").update({"counter": saleId + 1});
    return saleId;
  }

  ///Adds sale to database
  static void addSale(Sale sale, FirebaseFirestore firestore) async {
    Map<String, dynamic> map = sale.toMap();
    map["publishedDate"] = Timestamp.now();
    await firestore.collection('sales').doc(sale.saleID).set(map);
  }

  ///Updates sale in database
  static void updateSale(String description, String condition, int price,
      String saleID, FirebaseFirestore firestore) async {
    await firestore.collection('sales').doc(saleID).update({
      'description': description,
      'condition': condition,
      'price': price,
      'publishedDate': Timestamp.now()
    });
  }

  ///Removes sale from database
  static void removeSale(String saleID, FirebaseFirestore firestore) async {
    await firestore.collection('sales').doc(saleID).delete();
  }
}
