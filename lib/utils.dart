import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

///Utility class containing static methods used universally
class Utility {
  ///Display toast for user feedback
  static toastMessage(String toastMessage, int sec, Color color) {
    Fluttertoast.showToast(
        msg: toastMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: sec,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  ///For use in dropdown menus when editing/creating sale objects
  static final items = [
    "1. Poor",
    "2. Fair",
    "3. Good",
    "4. Very good",
    "5. Fine",
    "6. As new"
  ];
}
