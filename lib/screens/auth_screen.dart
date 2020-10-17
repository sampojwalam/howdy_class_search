import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
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
      }
    } on PlatformException catch (error) {
      var message = "An error occured, please try again!";
      if (error.message != null) {
        message = error.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
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
