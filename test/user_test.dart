import 'package:flutter/cupertino.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart';
import 'package:test/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  final firestore = FakeFirebaseFirestore();

  //Populate mock firestore AND firebase storage
  setUpAll(() async {
    await firestore.collection('courses').doc('0').set({
      'name': 'Programmering 1',
      'shortCode': 'PROG1',
      'code': 'IB133N',
      'literature': {
        'boken till prog1': ['isbn1', 'isbn2']
      },
      'isbnNumbers': ['123']
    });

    await firestore.collection('courses').doc('1').set({
      'name': 'PrototypkursN',
      'shortCode': 'PROTO',
      'code': 'IB711C',
      'literature': {
        'Prototyping:': ['123', '124']
      },
      'isbnNumbers': ['123']
    });

    await firestore.collection('courses').doc('2').set({
      'name': 'Spelbaserat lärande',
      'shortCode': 'SL',
      'code': 'IB530C',
      'literature': {
        'placeholder': ['456', '789']
      },
      'isbnNumbers': ['123']
    });

    await firestore.collection('users').doc('boomerFc').set({
      'name': 'Zlatan',
      'lastName': 'Ibrahamovic',
      'courses': ['PROG1', 'PROTO', 'SL'],
    });

    await firestore.collection('users').doc('ronaldo').set({
      'name': 'Christiano',
      'lastName': 'Ronaldo',
      'courses': ['PROG1', 'PROTO', 'SL'],
    });
  });

  group('User tests', () {
    test('Get User', () async {
      //Assert correct user fetch
      User user = await UserHandler.getUser('boomerFc', firestore);
      expect('Zlatan', user.name);
    });

    test('Get user stream', () async {
      StreamBuilder(
          stream: UserHandler.getUserStream('boomerFc', firestore),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User user = User.fromMap((snapshot.data as DocumentSnapshot)
                  .data() as Map<String, dynamic>);
              expect(user.name, 'Zlatan');
            }
            return Container();
          });
    });

    test('Update username', () async {
      await UserHandler.updateUsername(
          'boomerFc', 'Henrik', 'Larsson', firestore);
      User user = await UserHandler.getUser('boomerFc', firestore);
      expect(user.name, 'Henrik');
    });

    test('Send report', () async {
      QuerySnapshot query = await firestore.collection('reports').get();

      assert(query.docs.isEmpty);

      await UserHandler.sendReport(
          'boomerFc', 'ronaldo', 'he is too good at soccer', firestore);

      query = await firestore.collection('reports').get();

      assert(query.docs.isNotEmpty);
    });
  });
}
