import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationHandler {
  final FirebaseMessaging firebaseMessaging;

  NotificationHandler(this.firebaseMessaging);

  static Future updateToken() async {
    FirebaseMessaging.instance.getToken().then((token) => FirebaseFirestore.instance
        .collection('tokens')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'token': token,
    })
    );
  }

  Future initialise() async {
    await updateToken();

    //called when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.notification!.body);
      Fluttertoast.showToast(
          msg: 'Message received!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('init called onResume');
      // Fluttertoast.showToast(
      //     msg: 'Message received!',
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 2,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    });


    // If you want to test the push notification locally,
    // you need to get the token and input to the Firebase console
    // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose
  }
}