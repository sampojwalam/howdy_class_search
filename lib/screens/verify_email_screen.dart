import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:howdy_class_search/screens/auth_screen.dart';
import './classes_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  static const routeName = '/verify-email-screen';
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = FirebaseAuth.instance;
  User user;
  Timer timer;
  var email;

  @override
  void initState() {
    user = _auth.currentUser;
    email = user.email;
    user.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    user = _auth.currentUser;
    await user.reload();
    if (user.emailVerified) {
      timer.cancel();
      Navigator.of(context).pushReplacementNamed(ClassesScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: Center(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 250),
                Image(
                  image: AssetImage("assets/images/mail.png"),
                  height: 200,
                ),
                SizedBox(height: 30),
                Text(
                  "An verification link was sent to: $email. \nPlease verify your email to continue...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton.icon(
                      color: Colors.white,
                      icon: Icon(Icons.arrow_back),
                      label: Text("Back to sign in"),
                      onPressed: () {
                        timer.cancel();
                        Navigator.of(context)
                            .pushReplacementNamed(AuthScreen.routeName);
                      },
                    ),
                    RaisedButton.icon(
                      color: Colors.white,
                      icon: Icon(Icons.refresh),
                      label: Text("Refresh"),
                      onPressed: () {
                        checkEmailVerified();
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
