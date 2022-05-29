import 'package:flutter/cupertino.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  final firestore = FakeFirebaseFirestore();

  group('Chat tests', () {
    setUpAll(() async {
      await firestore.collection('users').doc('1').set({
        'name': 'Zlatan',
        'lastName': 'Ibrahamovic',
        'courses': ['PROG1', 'PROTO', 'SL'],
      });

      await firestore.collection('users').doc('2').set({
        'name': 'Henrik',
        'lastName': 'Larsson',
        'courses': ['EMDSV', 'ISBI'],
      });

      await ChatHandler.sendMessage(
          '1', '2', '3', 'hej', "anders", 'enSale', 'ettISBN', firestore);
    });

    test('Get messages', () async {
      dynamic chat = ChatHandler.getMessages('1-2-3', firestore);

      StreamBuilder(
          stream: chat,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              expect((snapshot.data as QuerySnapshot).docs.length, 1);
            }
            return Container();
          });
    });

    test('Get chat', () async {
      var chat = await ChatHandler.getChatById('1-2-3', firestore);
      expect((chat.data() as Map<String, dynamic>)["sellerId"], "enSale");
    });

    test('Get chats', () async {
      var chat = ChatHandler.getMessages('1', firestore);

      StreamBuilder(
          stream: chat,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              expect((snapshot.data as QuerySnapshot).docs.length, 1);
            }
            return Container();
          });
    });

    test('Generate chat ID', () async {
      expect(ChatHandler.generateChatId('a', 'b', 'c'), 'a-b-c');
    });

    test('Check for existing chat', () async {
      await ChatHandler.sendMessage(
          '1', '2', '3', 'hej', "anders", 'enSale', 'ettISBN', firestore);
      assert(await ChatHandler.checkChatExists('1', '2', '3', firestore));
    });

    test('Check whether chat is empty', () async {
      assert(!await ChatHandler.isChatEmpty('1-2-3', firestore));
    });

    test('Send message', () async {
      QuerySnapshot query = await firestore
          .collection('chats')
          .doc('1-2-3')
          .collection('messages')
          .get();

      expect(query.docs.length, 2);
    });

    test('Delete chat', () async {
      await ChatHandler.deleteChat('1-2-3', firestore);

      DocumentSnapshot chat =
          await firestore.collection('chats').doc('1-2-3').get();

      expect(chat.exists, false);
    });
  });
}
