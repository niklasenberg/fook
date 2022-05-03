import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/model/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  static Future<String> getPhotoUrl(String userId, FirebaseFirestore firestore) async {
    return FirebaseStorage.instance.ref().child(userId + ".png").getDownloadURL();
  }

  static void updateUsername(String username) async {

  }
}
