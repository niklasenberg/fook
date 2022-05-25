import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fook/handlers/notification_handler.dart';
import 'package:fook/screens/nav_page.dart';
import 'model/firebase_options.dart';
import 'screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/theme/colors.dart';

//import 'package:fook/widgets/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  MaterialColor fookOrange =
      CustomColors.createMaterialColor(const Color(0xFFFE8A13));

  MaterialColor fookRed =
      CustomColors.createMaterialColor(const Color(0xFFFE5608));

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: fookOrange,
          primarySwatch: fookOrange,
          highlightColor: fookRed,
          splashColor: CustomColors.createMaterialColor(const Color(0xFFE5E5E5)),
          backgroundColor: CustomColors.createMaterialColor(const Color(0xFFFFFFFF)),
          cardColor: Colors.white,
          fontFamily: 'Roboto',
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle:
                TextStyle(color: Colors.deepOrangeAccent, fontFamily: 'Roboto'),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepOrange),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            hintStyle: TextStyle(color: Colors.deepOrangeAccent),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrangeAccent),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrangeAccent),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(15))),
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
