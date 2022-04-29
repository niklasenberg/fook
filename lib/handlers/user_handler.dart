import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/model/user.dart';

class UserHandler {
  static Future<User> getUser(
      String userId, FirebaseFirestore firestore) async {
    DocumentSnapshot document =
        await firestore.collection('users').doc(userId).get();

    return User.fromMap(document.data() as Map<String, dynamic>);
  }

  static addUser(User user) async {
    FirebaseFirestore.instance
        .collection('users')
        .add(user.toMap())
        .then((value) => print('Student added'));
  }

  static void updateUsername(String username) async {

  }

  static Future<String> getCourseDocumentID(String shortCode) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('courseTest')
        .where('shortCode', isEqualTo: shortCode)
        .get();

    return query.docs[0].id;
  }
}
