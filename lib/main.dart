import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fook/handlers/notification_handler.dart';
import 'package:fook/widgets/nav_page.dart';
import 'model/firebase_options.dart';
import 'widgets/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/theme/colors.dart';

//import 'package:fook/widgets/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: CustomColors.createMaterialColor(Color(0xFFFE7F18)),
          primarySwatch: CustomColors.createMaterialColor(Color(0xFFFE7F18)),
          backgroundColor: Colors.grey.shade800,
          cardColor: CustomColors.createMaterialColor(Color(0xFFFE7F18)),
          fontFamily: 'Roboto',
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle:
                TextStyle(color: Colors.deepOrangeAccent, fontFamily: 'Roboto'),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepOrangeAccent),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            hintStyle: TextStyle(color: Colors.deepOrangeAccent),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrangeAccent),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrangeAccent),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(25))),
          )),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return const Center(
              child: Text('Something went wrong!'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final notificationService =
                NotificationHandler(FirebaseMessaging.instance);
            notificationService.initialise();
            return handleHomePage();
          }

          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

Widget handleHomePage() {
  return StreamBuilder(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      } else if (snapshot.hasData) {
        return const NavPage();
      } else {
        return const LoginPage();
      }
    },
  );
}
