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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        }
      },
      builder: (context, state, controller, _) {
        if (state is AwaitingEmailAndPassword) {
          return Column(
            children: [
              TextField(controller: emailCtrl),
              TextField(controller: passwordCtrl),
              ElevatedButton(
                onPressed: () {
                  controller.setEmailAndPassword(
                    emailCtrl.text,
                    passwordCtrl.text,
                  );
                },
                child: const Text('Sign in'),
              ),
            ],
          );
        } else if (state is SigningIn) {
          return Center(child: CircularProgressIndicator());
        } else if (state is AuthFailed) {
          // FlutterFireUIWidget that shows a human-readable error message.
          return ErrorText(exception: state.exception);
        } else{
          return const LoginPage();
        }
      },
    );
  }
}
