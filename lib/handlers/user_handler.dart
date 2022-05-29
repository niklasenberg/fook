import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/model/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

///Handler class that fetches/writes users data
class UserHandler {
  ///Given a user Id, returns a User object of corresponding user
  static Future<User> getUser(
      String userId, FirebaseFirestore firestore) async {
    DocumentSnapshot document =
        await firestore.collection('users').doc(userId).get();

    return User.fromMap(document.data() as Map<String, dynamic>);
  }

  ///Given a user Id, returns a stream of user data
  ///Is needed due to realtime updates of username etc
  static Stream<DocumentSnapshot> getUserStream(
      String userId, FirebaseFirestore firestore) {
    return firestore.collection('users').doc(userId).snapshots();
  }

  ///Given a user Id, returns a String URL for that users profile picture
  static Future<String> getPhotoUrl(
      String userId, FirebaseStorage storage) async {
    return storage.ref().child(userId + ".png").getDownloadURL();
  }

  ///Given a user id, name and lastName, updates that users information.
  static Future<bool> updateUsername(String uid, String name, String lastName,
      FirebaseFirestore firestore) async {
    firestore
        .collection("users")
        .doc(uid)
        .update({"name": name, "lastName": lastName});
    return true;
  }

  ///Given a reported user id, the reporters id, the report message,
  ///creates a report document in the database. Triggers server function which
  ///sends email corresponding to database document.
  static sendReport(String reportedUser, String from, String message,
      FirebaseFirestore firestore) {
    firestore.collection('reports').add({
      "to": ["nickeen95@gmail.com"],
      "message": {
        "subject": "Report regarding " + reportedUser,
        "text": "Reported user: " +
            reportedUser +
            "\n" +
            "Reported by: " +
            from +
            "\n" +
            "Reason: " +
            message,
        "html": "Reported user: " +
            reportedUser +
            "\n" +
            "Reported by: " +
            from +
            "\n" +
            "Reason: " +
            message
      }
    });
  }
}
