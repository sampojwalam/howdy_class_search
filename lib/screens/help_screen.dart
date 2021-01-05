import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/globals.dart' as globals;
import './auth_screen.dart';
import './classes_screen.dart';

class HelpScreen extends StatefulWidget {
  static const routeName = '/help-screen';

  @override
  __HelpScreenStateState createState() => __HelpScreenStateState();
}

class __HelpScreenStateState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
