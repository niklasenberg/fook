import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHandler {
  
  static getChat(
      String userId, String myId, saleId, FirebaseFirestore firestore) {
    String chatId = generateChatId(userId, myId, saleId);
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getChats(
      String uId, FirebaseFirestore firestore) {
    return firestore
        .collection("chats")
        .where("members", arrayContains: uId)
        //.orderBy("lastActive", descending: true)
        .snapshots();
  }

  static String generateChatId(
      String username1, String username2, String saleId) {
    String chatId = username1.toString().compareTo(username2.toString()) < 0
        ? username1.toString() + '-' + username2.toString()
        : username2.toString() + '-' + username1.toString();

    return chatId + '-' + saleId;
  }

  static Future<bool> checkChatExists(String username1, String username2,
      String saleId, FirebaseFirestore firestore) async {
    String chatId = generateChatId(username1, username2, saleId);
    DocumentSnapshot doc =
        await firestore.collection('chats').doc(chatId).get();
    return doc.exists;
  }

  static Future<void> deleteChat(String chatId, FirebaseFirestore firebase) async {
    QuerySnapshot querySnapshot = await firebase.collection('chats').doc(chatId).collection('messages').get();
    for (var message in querySnapshot.docs) {
      await message.reference.delete();
    }
    firebase.collection('chats').doc(chatId).collection('messages');
    return firebase.collection('chats').doc(chatId).delete();
  }

  static sendMessage(String to, String from, String saleId, bool isText,
      String msg, String senderName, FirebaseFirestore firestore) async {
    bool existsOrNot = await checkChatExists(to, from, saleId, firestore);
    String chatId = generateChatId(from, to, saleId);
    Timestamp now = Timestamp.now();
    if (!existsOrNot) {
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
      /*isText
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
            );*/

      await firestore.collection('chats').doc(chatId).set({
        'lastActive': now,
        'members': members,
        'saleId': saleId,
        'chatId': chatId
      });
    } else {
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
      /*isText
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
            );*/
      await firestore
          .collection('chats')
          .doc(chatId)
          .update({'lastActive': now});
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
