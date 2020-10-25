import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/globals.dart' as globals;

class AddClassScreen extends StatefulWidget {
  static const routeName = '/add-class';

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _crnController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Add a New Class"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                // Color(0xFF400000),
                // Color(0xFF900000),
                Colors.green,
                Colors.lightGreen,
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  gapPadding: 5.0,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(20.0),
                  ),
                ),
                labelText: "CRN",
              ),
              controller: _crnController,
            ),
          ),
          RaisedButton.icon(
            onPressed: () async {
              final crn = _crnController.text.trim();
              if (crn.length != 5) {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  backgroundColor: Theme.of(context).errorColor,
                  content: Text("Invalid CRN. Please enter a valid CRN."),
                ));

                return;
              }
              final uid = FirebaseAuth.instance.currentUser.uid;
              //const url = "https://cap1.herpin.net:5000/add";
              final url = "${globals.urlStem}/add";
              final payload = jsonEncode({'crn': crn, 'uid': uid});
              final response = await http.post(url,
                  headers: {'Content-Type': 'application/json'}, body: payload);
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: Text(
              "Add Class",
              style: TextStyle(color: Colors.white),
            ),
            elevation: 0,
            color: Theme.of(context).primaryColor,
            //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )
        ],
      ),
    );
  }
}
