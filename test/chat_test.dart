import 'package:flutter/cupertino.dart';
import 'package:fook/handlers/chat_handler.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  final firestore = FakeFirebaseFirestore();
  
  group('Chat tests', () {
    setUp(() async {
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
    });


    test('Get chat', () async {
      dynamic chat = await ChatHandler.getChat('1', '2', firestore);

      StreamBuilder(
          stream: chat,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              expect((snapshot.data as QuerySnapshot).docs.length, 1);
            }
            return Container();
          });
    });

    test('Get chats', () async {
      dynamic chat = await ChatHandler.getChat('1', '2', firestore);

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
      expect(ChatHandler.generateChatId('a', 'b'), 'a-b');
    });

    test('Check for existing chat', () async {
      await ChatHandler.sendMessage('1', '2', true, 'hej', "anders", firestore);
      expect(await ChatHandler.checkChatExists('1', '2', firestore), true);
    });

    test('Send message', () async {
      await ChatHandler.sendMessage('3', '4', true, 'hej', "anders", firestore);

      QuerySnapshot query = await firestore.collection('chats').doc('3-4').collection('messages').get();

      expect(query.docs.length, 1);

    });
  });
}