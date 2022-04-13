import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:fook/handlers/course_handler.dart';
import 'home_page.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:string_validator/string_validator.dart';
import 'package:fook/model/course.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).backgroundColor,
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  LoginForm({Key? key}) : super(key: key);

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Course course = Course(name: 'Programmering 2', shortCode: 'PROG2', code: 'IB332N', literature: ['234235345','','']);

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      listener: (oldState, state, controller) {
        if (state is SignedIn) {
          CourseHandler.addCourse(course);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
        } else if (state is AuthFailed) {
          Fluttertoast.showToast(
              msg: 'Login or password is invalid',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.deepOrangeAccent,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      },
      builder: (context, state, controller, _) {
        if (state is AwaitingEmailAndPassword) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign in with Daisy',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Roboto',
                            fontSize: 20.0),
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
                                return 'Username can\'t be empty!';
                              } else if (value.length != 8 ||
                                  !isAlpha(value.substring(0, 3)) ||
                                  !isNumeric(value.substring(4, 7))) {
                                return 'Wrong format, should be abcd1234';
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                            controller: emailCtrl),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can\'t be empty!';
                              }
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                              labelText: 'Password',
                            ),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      fixedSize: Size(200, 30.0),
                      primary: Colors.deepOrangeAccent,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is SigningIn) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Container();
        }
      },
    );
  }
}
