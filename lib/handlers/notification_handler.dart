import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

///Handler class that declares options for using push notifications
class NotificationHandler {
  final FirebaseMessaging firebaseMessaging;

  NotificationHandler(this.firebaseMessaging);

  ///Updates the push token for the logged in user, in the database
  static Future updateToken() async {
    FirebaseMessaging.instance.getToken().then((token) => FirebaseFirestore
            .instance
            .collection('tokens')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'token': token,
        }));
  }

  Future initialise() async {
    await updateToken();

    //Called when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.notification!.body);
    });

    //Called when app is opened via message
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('init called onResume');
    });
  }
}
