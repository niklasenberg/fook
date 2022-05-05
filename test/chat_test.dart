import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

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
      
      await firestore.collection('chats').doc('12').set({});
    });
    
    
    test('Get chat', () async {


    });
  });
}