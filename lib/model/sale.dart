import 'package:fook/model/course.dart';

class Sale {
  final String isbn;
  final String userID;
  final List<String> courses;
  String condition;
  int price;
  final String saleID;

  Sale({
    required this.isbn,
    required this.userID,
    required this.courses,
    required this.condition,
    required this.price,
    required this.saleID,
  });

  factory Sale.fromMap(Map<String, dynamic> data) {
    return Sale(
      isbn: data['isbn'],
      userID: data['userID'],
      courses: List<String>.from(data['courses']),
      condition: data['condition'],
      price: data['price'],
      saleID: data['saleID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isbn': isbn,
      'userID': userID,
      'courses': courses,
      'condition': condition,
      'price': price,
      'saleID': saleID,
    };
  }

  int changePrice(int newPrice) {
    return price = newPrice;
  }

  changeCondition(String c) {
    return condition = c;
  }

  String getIsbn() {
    return isbn;
  }

  List<String> getCourses() {
    return courses;
  }

  String getuserID() {
    return userID;
  }

  int getPrice() {
    return price;
  }

  String getSaleID() {
    return saleID;
  }

  bool operator ==(Object other) {
    // Long calculation involving a, b, c, d etc.

    return other is Sale && other.saleID == saleID;
  }

  @override
  String toString() {
    return isbn +
        " " +
        userID +
        " " +
        courses.toString() +
        " " +
        condition +
        " " +
        price.toString() +
        " " +
        saleID;
  }
}
