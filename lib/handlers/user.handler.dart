import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/model/user.dart';

class StudentHandler {
  static Future<Type> getStudent(String userId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('DocumentId', isEqualTo: userId)
        .get();

    return User; //Handlar om att JEremy inte pushat student än
  }

  static addUser(User user) async {
    FirebaseFirestore.instance
        .collection('users')
        .add(user)
        .then((value) => print('Student added'));
  }

  static void updateUsername(String userName) async {}

  static Future<String> getCourseDocumentID(String shortCode) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('courseTest')
        .where('shortCode', isEqualTo: shortCode)
        .get();

    return query.docs[0].id;
  }
}
