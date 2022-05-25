import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:fook/handlers/notification_handler.dart';
import 'package:fook/screens/nav_page.dart';
import 'package:string_validator/string_validator.dart';

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

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool termsAgreed = false;

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      listener: (oldState, state, controller) {
        if (state is SignedIn) {
          NotificationHandler.updateToken();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const NavPage()));
        } else if (state is AuthFailed) {
          Fluttertoast.showToast(
              msg: 'Login or password is invalid',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      },
      builder: (context, state, controller, _) {
        if (state is AwaitingEmailAndPassword || state is AuthFailed) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.5, 0.5),
                    blurRadius: 1,
                  ),
                ], borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xffeae6e6),
                    Color(0xfffafafa),
                    Color(0xfffaf4f4),
                    Color(0xffe5e3e3)
                  ],
                ),),child: Column(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign in with Daisy',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Theme.of(context).highlightColor,
                            fontFamily: 'Roboto',
                            fontSize: 20.0),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username can\'t be empty!';
                              } else if (value.length != 8 ||
                                  !isAlpha(value.substring(0, 3)) ||
                                  !isNumeric(value.substring(4, 7))) {
                                return 'Wrong format, should be abcd1234';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            style: TextStyle(
                                color: Theme.of(context).highlightColor),
                            controller: emailCtrl),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can\'t be empty!';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                              labelText: 'Password',
                            ),
                            style: TextStyle(
                                color: Theme.of(context).highlightColor),
                            controller: passwordCtrl),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(width: 350,
                          child: ListTile(
                            leading: Checkbox(
                              activeColor: Theme.of(context).highlightColor,
                              value: termsAgreed,
                              onChanged: (nValue) {
                                setState(() {
                                  termsAgreed = nValue!;
                                });
                              },

                            ),
                            title: Text("I agree to the terms and conditions", style: TextStyle(color: Theme.of(context).highlightColor)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && termsAgreed) {
                        controller.setEmailAndPassword(
                          emailCtrl.text + '@test.com',
                          passwordCtrl.text,
                        );
                      }
                    },
                    child: const Text('Sign in', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      fixedSize: const Size(200, 30.0),
                      primary: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),)
            ),
          );
        } else if (state is SigningIn) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const LoginPage();
        }
      },
    );
  }
}