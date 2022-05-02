import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fook/model/chat.dart';

class ChatHandler {
  static Stream<QuerySnapshot> getChats(String uId) {
    return FirebaseFirestore.instance
        .collection("chats")
        .where("members", arrayContains: uId)
        .orderBy("lastActive", descending: true)
        .snapshots();
  }

  static String generateChatId(String username1, String username2) {
    return username1.toString().compareTo(username2.toString()) < 0
        ? username1.toString() + '-' + username2.toString()
        : username2.toString() + '-' + username1.toString();
  }

  Future<bool> checkChatExistsOrNot(
      {@required tring username1, @required String username2}) async {
    String chatId = generateChatId(username1: username1, username2: username2);
    DocumentSnapshot doc = await _db.collection('chats').doc(chatId).get();
    return doc.exists;
  }
}
