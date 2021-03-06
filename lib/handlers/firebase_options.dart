import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkv0pymB7OlIGJGF9cHoffdTjq148ruYQ',
    appId: '1:293825347027:android:ca4eb491260620c1a4c326',
    messagingSenderId: '293825347027',
    projectId: 'fook-604f3',
    storageBucket: 'fook-604f3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWlreR5ilcF5E2WQRcQ_wlfkm0oIj2bSE',
    appId: '1:293825347027:ios:90807b4dede4a6a3a4c326',
    messagingSenderId: '293825347027',
    projectId: 'fook-604f3',
    storageBucket: 'fook-604f3.appspot.com',
    iosClientId:
        '293825347027-uun7qb3iboetjsvgeo07f78l4ccn2kn7.apps.googleusercontent.com',
    iosBundleId: 'com.example.fook',
  );
}
