///Sale object, contains information such as condition, price, etc
class Sale {
  final String isbn;
  final String userID; //Sellers user ID
  final List<String> courses; //List of courses that sale object is relevant for
  final String description; //Sellers comments
  String condition;
  int price;
  final String saleID; //Document ID

  Sale({
    required this.isbn,
    required this.userID,
    required this.courses,
    required this.condition,
    required this.price,
    required this.saleID,
    required this.description,
  });

  factory Sale.fromMap(Map<String, dynamic> data) {
    return Sale(
      isbn: data['isbn'],
      userID: data['userID'],
      courses: List<String>.from(data['courses']),
      condition: data['condition'],
      price: data['price'],
      saleID: data['saleID'],
      description: data['description'],
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
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
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

  @override
  int get hashCode => saleID.hashCode;
}
