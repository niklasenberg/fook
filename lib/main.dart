import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fook/handlers/notification_handler.dart';
import 'package:fook/screens/nav_page.dart';
import 'handlers/firebase_options.dart';
import 'screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fook/theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

///Initializer class for app
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  ///Initilization of firebase connection
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightMode(),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong!' + snapshot.error.toString()),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            //Init push notification services
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

  ///Listener to ensure user is logged in
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
}

///ThemeData for light mode devices
ThemeData lightMode() {
  return ThemeData(
      unselectedWidgetColor: CustomColors.fookOrange,
      primaryColor: CustomColors.fookOrange,
      primarySwatch: CustomColors.fookOrange,
      highlightColor: CustomColors.fookRed,
      splashColor: CustomColors.createMaterialColor(const Color(0xFFE5E5E5)),
      backgroundColor:
          CustomColors.createMaterialColor(const Color(0xFFFFFFFF)),
      cardColor: Colors.white,
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        labelStyle:
            TextStyle(color: CustomColors.fookOrange, fontFamily: 'Roboto'),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: CustomColors.fookOrange),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        hintStyle: TextStyle(color: CustomColors.fookOrange),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.fookOrange),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.fookRed),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.fookRed),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.fookRed),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
      ));
}
