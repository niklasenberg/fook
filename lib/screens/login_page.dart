import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:fook/handlers/notification_handler.dart';
import 'package:fook/screens/nav_page.dart';
import 'package:fook/theme/colors.dart';
import 'package:string_validator/string_validator.dart';

import '../utils.dart';

///Page presented to user on first boot
///or when not in logged in state
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Controllers
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  //Input validation
  final _formKey = GlobalKey<FormState>();
  bool termsAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).backgroundColor,
        body: _loginForm());
  }

  ///Form with textfields and checkbox for ToS, all input validated
  Widget _loginForm() {
    return AuthFlowBuilder<EmailFlowController>(
      listener: (oldState, state, controller) {
        if (state is SignedIn) {
          //Successful login
          NotificationHandler.updateToken();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const NavPage()));
        } else if (state is AuthFailed) {
          //Failed login
          Utility.toastMessage("Login or password is invalid", 1, Colors.red);
        }
      },
      builder: (context, state, controller, _) {
        //Waiting or failed login
        if (state is AwaitingEmailAndPassword || state is AuthFailed) {
          return SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: CustomColors.fookGradient,
                    ),
                  ),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  labelText: 'Password',
                                ),
                                style: TextStyle(
                                    color: Theme.of(context).highlightColor),
                                controller: passwordCtrl),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 350,
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
                                title: RichText(
                                    text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  TextSpan(
                                      text: 'Terms of Service',
                                      style:
                                          const TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _termsDialog(context);
                                        }),
                                ])),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          //Input validation
                          if (_formKey.currentState!.validate() &&
                              termsAgreed) {
                            controller.setEmailAndPassword(
                              emailCtrl.text + '@test.com',
                              passwordCtrl.text,
                            );
                          }
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          fixedSize: const Size(200, 30.0),
                          primary: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                )),
          );
        } else if (state is SigningIn) {
          //Logging in
          return const Center(child: CircularProgressIndicator());
        } else {
          //Does not happen
          return const LoginPage();
        }
      },
    );
  }
}

///Helper method for displaying ToS
_termsDialog(BuildContext context) {
  String terms =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eget tempor sem. Nulla vulputate scelerisque sem, eget volutpat magna porttitor et. Proin malesuada, urna sed sagittis dignissim, sem dolor auctor diam, sed vehicula purus libero ut neque. Fusce commodo dictum libero. Nulla pulvinar tincidunt erat, at consequat erat sodales vel. Ut eget aliquet ex, a pharetra neque. Sed mattis, sem a dapibus convallis, mi lacus feugiat odio, non bibendum ante sem sed turpis. Quisque semper, ex ut convallis aliquet, odio libero lacinia diam, et convallis ante purus nec ligula. Nunc pretium tortor id risus bibendum tincidunt. Aenean eget iaculis mi, a sodales felis. Duis feugiat molestie turpis ut rhoncus. Suspendisse faucibus porta purus, at porttitor erat venenatis at. Maecenas vitae quam eros.";

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 3),
            ),
            contentPadding: const EdgeInsets.only(top: 10.0),
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text(
                      "Terms of Service",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Scrollbar(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      terms,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
      });
}
