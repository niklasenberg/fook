import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:flutterfire_ui/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  LoginForm({Key? key}) : super(key: key);

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      listener: (oldState, state, controller) {
        if (state is SignedIn) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        }
      },
      builder: (context, state, controller, _) {
        if (state is AwaitingEmailAndPassword) {
          return Column(
            children: [
              Container(
                width: 300.0,
                height: 300.0,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    'lib/assets/logo_o.png',
                    scale: 0.5,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sign in with Daisy',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                        controller: emailCtrl),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                        controller: passwordCtrl),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),
              ElevatedButton(
                onPressed: () {
                  controller.setEmailAndPassword(
                    emailCtrl.text,
                    passwordCtrl.text,
                  );
                },
                child: const Text('Sign in'),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(120.0, 30.0),
                ),
              ),
            ],
          );
        } else if (state is SigningIn) {
          return Center(child: CircularProgressIndicator());
        } else if (state is AuthFailed) {
          // FlutterFireUIWidget that shows a human-readable error message.
          return SnackBar(content: Text(state.exception.toString()));
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
