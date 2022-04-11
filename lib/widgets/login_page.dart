import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:string_validator/string_validator.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  LoginForm({Key? key}) : super(key: key);

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      listener: (oldState, state, controller) {
        if (state is SignedIn) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } else if (state is AuthFailed) {
          Fluttertoast.showToast(
              msg: 'Login or password is invalid',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.deepOrangeAccent,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      },
      builder: (context, state, controller, _) {
        if (state is AwaitingEmailAndPassword) {
          return Form(
            key: _formKey,
            child: Column(
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sign in with Daisy',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            } else if (value.length != 8 || !isAlpha(value.substring(0,3)) || !isNumeric(value.substring(4,7))) {
                              return 'Wrong format, should be abcd1234';
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                          ),
                          controller: emailCtrl),
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0)),
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
                    if (_formKey.currentState!.validate()) {
                      controller.setEmailAndPassword(
                        emailCtrl.text + '@test.com',
                        passwordCtrl.text,
                      );
                    }
                  },
                  child: const Text('Sign in'),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(120.0, 30.0),
                    primary: Colors.deepOrangeAccent,
                  ),
                ),
              ],
            ),
          );
        } else if (state is SigningIn) {
          return Center(child: CircularProgressIndicator());
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
