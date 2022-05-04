import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHandler {
  static getUserByUsername(String username, FirebaseFirestore firestore) async {
    return await firestore.collection('users').doc(username).get();
  }

  static getChat(
    String userId,
    String myId,
  ) {
    String chatId = generateChatId(userId, myId);
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

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

  static Future<bool> checkChatExistsOrNot(
      String username1, String username2) async {
    String chatId = generateChatId(username1, username2);
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    return doc.exists;
  }

  static sendMessage(
    String to,
    String from,
    bool isText,
    String msg,
    String path,
  ) async {
    bool existsOrNot = await checkChatExistsOrNot(to, from);
    FirebaseFirestore tempDb = FirebaseFirestore.instance;
    String chatId = generateChatId(from, to);
    Timestamp now = Timestamp.now();
    if (!existsOrNot) {
      List<String> members = [to, from];
      isText
          ? await tempDb
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add(
              {'from': from, 'message': msg, 'time': now, 'isText': true},
            )
          : await tempDb
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add(
              {'from': from, 'photo': path, 'time': now, 'isText': false},
            );
      await tempDb
          .collection('chats')
          .doc(chatId)
          .set({'lastActive': now, 'members': members});
    } else {
      isText
          ? await tempDb
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add(
              {'from': from, 'message': msg, 'time': now, 'isText': true},
            )
          : await tempDb
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add(
              {'from': from, 'photo': path, 'time': now, 'isText': false},
            );
      await tempDb.collection('chats').doc(chatId).update({'lastActive': now});
    }
  }

  /* uploadImage(
    File image,
    String to,
    String from,
  ) {
    String chatId = generateChatId(to, from);
    String filePath = 'chatImages/$chatId/${DateTime.now()}.png';
    _uploadTask = _firebaseStorage.ref().child(filePath).putFile(image);
    return _uploadTask;
  }*/

  /* getURLforImage(String imagePath) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference sRef =
        await storage.getReferenceFromUrl(Constants.firebaseReferenceURI);
    StorageReference pathReference = sRef.child(imagePath);
    return await pathReference.getDownloadURL();
  }*/
}
