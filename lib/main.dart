import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fook/widgets/home_page.dart';
import 'model/firebase_options.dart';
import 'widgets/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Widget firstPage = FirebaseAuth.instance.currentUser == null
      ? const LoginPage()
      : const HomePage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          backgroundColor: Colors.black26,
          fontFamily: 'Roboto',
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.deepOrangeAccent,
                fontFamily: 'Roboto'),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepOrangeAccent),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
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
      home: firstPage,
    );
  }
}
