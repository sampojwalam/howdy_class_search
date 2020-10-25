import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:howdy_class_search/screens/classes_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/globals.dart' as globals;
import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  Future<void> _submitAuthForm(
    String email,
    String phone,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) async {
    setState(() {
      _isLoading = true;
    });
    Scaffold.of(context).removeCurrentSnackBar();
    if (isLogin) {
      _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) =>
              Navigator.of(context).pushNamed(ClassesScreen.routeName))
          .catchError(
        (error) {
          Scaffold.of(ctx).showSnackBar(
            SnackBar(
              content: Text("Invalid credentials! Please try again!"),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          setState(
            () {
              _isLoading = false;
            },
          );
        },
      );
    } else {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        final uid = FirebaseAuth.instance.currentUser.uid;
        print(uid);
        //const url = "https://cap1.herpin.net:5000/add";
        final url = "${globals.urlStem}/addUser";
        final payload = jsonEncode({
          'uid': uid,
          'email': email,
          'phone': phone,
          'name': '',
          'notification': '1'
        });
        final response = await http.post(url,
            headers: {'Content-Type': 'application/json'}, body: payload);

        FirebaseMessaging fbmInstance = FirebaseMessaging();
        fbmInstance.requestNotificationPermissions();
        fbmInstance.configure(onMessage: (msg) {
          return;
        }, onLaunch: (msg) {
          return;
        }, onResume: (msg) {
          return;
        });
        fbmInstance.subscribeToTopic("$uid");
        Navigator.of(context).pushNamed(ClassesScreen.routeName);
      }).catchError(
        (error) {
          Scaffold.of(ctx).showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          setState(
            () {
              _isLoading = false;
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
