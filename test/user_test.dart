import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/user.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('User tests', () {
    test('Get UserName', () async {
      //Populate mock firestore
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('boomerFc').set({
        'name': 'Zlatan',
        'lastName': 'Ibrahamovic',
        'courses': ['Samsung ads', 'Buy hammarby', 'betray malmö'],
      });
      User user = await UserHandler.getUser('boomerFc', firestore);
      expect('Zlatan', user.getName());
    });
  });
}
