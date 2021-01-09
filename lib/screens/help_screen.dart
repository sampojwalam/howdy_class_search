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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Help"),
      ),
      body: Text("Contact caleb.herpin@gmail.com for help."),
    );
  }
}
