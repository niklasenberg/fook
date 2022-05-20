import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/model/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fook/handlers/course_handler.dart';
import 'package:fook/model/course.dart';

class UserHandler {
  static Future<User> getUser(
      String userId, FirebaseFirestore firestore) async {
    DocumentSnapshot document =
        await firestore.collection('users').doc(userId).get();

    return User.fromMap(document.data() as Map<String, dynamic>);
  }

  static Stream<DocumentSnapshot> getUserStream(String userId, FirebaseFirestore firestore){
    return firestore.collection('users').doc(userId).snapshots();
  }

  static getUserSnapshot(String uId, FirebaseFirestore firestore) async {
    return await firestore.collection('users').doc(uId).get();
  }

  static addUser(User user) async {
    FirebaseFirestore.instance
        .collection('users')
        .add(user.toMap());
  }

  static Future<String> getPhotoUrl(
      String userId, FirebaseFirestore firestore) async {
    return FirebaseStorage.instance
        .ref()
        .child(userId + ".png")
        .getDownloadURL();
  }

  static Future<bool> updateUsername(String uid, String name, String lastName, FirebaseFirestore firestore) async {
    firestore.collection("users").doc(uid).update({"name": name, "lastName": lastName});
    return true;
  }
}
