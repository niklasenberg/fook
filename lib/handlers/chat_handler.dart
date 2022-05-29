import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/handlers/user_handler.dart';

import '../model/sale.dart';
import 'book_handler.dart';

///Handler class that fetches/writes data concerning user's chats
class ChatHandler {
  ///Given a chat ID, returns stream of messages for that chat
  static Stream<QuerySnapshot> getMessages(
      String chatId, FirebaseFirestore firestore) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  ///Given a chat Id, return a DocumentSnapshot from the database
  static Future<DocumentSnapshot> getChatById(
      String chatId, FirebaseFirestore firestore) {
    return firestore.collection('chats').doc(chatId).get();
  }

  ///Given a user ID, returns a stream of chats for that user
  static Stream<QuerySnapshot> getChats(
      String uId, FirebaseFirestore firestore) {
    return firestore
        .collection("chats")
        .where("members", arrayContains: uId)
        .orderBy("lastActive", descending: true)
        .snapshots();
  }

  ///Given another user ID, a sale ID and a chat Id, return a Map
  ///containing the information needed to construct a chat interaction
  ///in chat_detailed_page
  static Future<Map<String, dynamic>> getChatInfo(
      String myId,
      String userId,
      String saleId,
      String chatId,
      FirebaseFirestore firestore,
      FirebaseStorage firebaseStorage) async {
    Map<String, dynamic> result = {};

    //Initial parameters
    result['userId'] = userId;
    result['chatId'] = chatId;
    result['saleId'] = saleId;
    result['otherUser'] = await UserHandler.getUser(userId, firestore);
    result['thisUser'] = await UserHandler.getUser(myId, firestore);
    result['photoUrl'] = await UserHandler.getPhotoUrl(userId, firebaseStorage);
    result['sale'] = await SaleHandler.getSaleByID(saleId, firestore);

    if (await checkChatExists(userId, myId, saleId, firestore)) {
      DocumentSnapshot chat = await getChatById(chatId, firestore);
      result['saleISBN'] =
          ((chat.data() as Map<String, dynamic>)['saleISBN'] as String);
      result['sellerId'] =
          ((chat.data() as Map<String, dynamic>)['sellerId'] as String);
    } else {
      result['saleISBN'] = (result['sale'] as Sale).isbn;
      result['sellerId'] = userId;
    }

    if ((result['sale'] as Sale).isbn != "0") {
      result['book'] = await BookHandler.getBook((result['sale'] as Sale).isbn);
    } else {
      result['book'] =
          await BookHandler.getBook((result['saleISBN'] as String));
    }

    return result;
  }

  ///Given two user IDs and a sale ID, generate a unique ID for that interaction
  static String generateChatId(
      String username1, String username2, String saleId) {
    String chatId = username1.toString().compareTo(username2.toString()) < 0
        ? username1.toString() + '-' + username2.toString()
        : username2.toString() + '-' + username1.toString();

    return chatId + '-' + saleId;
  }

  ///Given two user IDs and a sale ID, check whether chat already exists for that interaction
  static Future<bool> checkChatExists(String username1, String username2,
      String saleId, FirebaseFirestore firestore) async {
    String chatId = generateChatId(username1, username2, saleId);
    DocumentSnapshot doc =
        await firestore.collection('chats').doc(chatId).get();
    return doc.exists;
  }

  ///Given a chat Id, check whether the chat has any messages
  static Future<bool> isChatEmpty(
      String chatId, FirebaseFirestore firestore) async {
    var query = await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    return query.docs.isEmpty;
  }

  ///Sends and stores message for a specific interaction between two users, given the following parameters:
  ///to: user Id of receiver
  ///from: user Id of sender,
  ///saleId: sale Id of object which chat is about
  ///msg: String of message contents
  ///senderName: first and lastname of sending user
  ///sellerId: user Id of sale owner
  ///saleISBN: ISBN number of sale object
  static sendMessage(
      String to,
      String from,
      String saleId,
      String msg,
      String senderName,
      String sellerId,
      String saleISBN,
      FirebaseFirestore firestore) async {
    //Establish whether interaction already exists
    bool chatExists = await checkChatExists(to, from, saleId, firestore);
    String chatId = generateChatId(from, to, saleId);
    Timestamp now = Timestamp.now();
    if (!chatExists) {
      //If not, send message and establish all parameters
      List<String> members = [to, from];
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(
        {
          'to': to,
          'from': from,
          'message': msg,
          'time': now,
          'isText': true,
          'senderName': senderName
        },
      );
      await firestore.collection('chats').doc(chatId).set({
        'lastActive': now,
        'members': members,
        'saleId': saleId,
        'chatId': chatId,
        'saleISBN': saleISBN,
        'sellerId': sellerId,
      });
    } else {
      //If so, send message and update "lastActive" field
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(
        {
          'to': to,
          'from': from,
          'message': msg,
          'time': now,
          'isText': true,
          'senderName': senderName
        },
      );
      await firestore
          .collection('chats')
          .doc(chatId)
          .update({'lastActive': now});
    }
  }

  ///Given a chat Id, delete that chat from the database
  static Future<void> deleteChat(
      String chatId, FirebaseFirestore firebase) async {
    QuerySnapshot querySnapshot = await firebase
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();
    for (var message in querySnapshot.docs) {
      await message.reference.delete();
    }
    firebase.collection('chats').doc(chatId).collection('messages');
    return firebase.collection('chats').doc(chatId).delete();
  }
}
