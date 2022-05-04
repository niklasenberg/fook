enum Condition { bad, good, shit }

class Sale {
  final String isbn;
  final String userID;
  final String course;
  Condition condition;
  int price;
  final String saleID;

  Sale({
    required this.isbn,
    required this.userID,
    required this.course,
    required this.condition,
    required this.price,
    required this.saleID,
  });

  factory Sale.fromMap(Map<String, dynamic> data) {
    return Sale(
      isbn: data['isbn'],
      userID: data['userID'],
      course: data['course'],
      condition: data['condition'],
      price: data['price'],
      saleID: data['saleID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isbn': isbn,
      'userID': userID,
      'course': course,
      'condition': condition,
      'price': price,
      'saleID': saleID,
    };
  }

  int changePrice(int newPrice) {
    return price = newPrice;
  }

  changeCondition(Condition c) {
    return condition = c;
  }

  String getIsbn() {
    return isbn;
  }

  String getCourse() {
    return course;
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
}
