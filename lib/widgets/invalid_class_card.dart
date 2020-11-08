import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/globals.dart' as globals;

class InvalidClassCard extends StatelessWidget {
  final String crn;
  Function updateClasses;

  InvalidClassCard(this.crn, this.updateClasses) {
    globals.incrementable++;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            height: 130.0,
            width: 15.0,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 30.0),
              height: 130.0,
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: Text("$crn is not a valid CRN.",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontSize: 18.0,
                      )),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            height: 130.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        final uid = FirebaseAuth.instance.currentUser.uid;
                        final url = "${globals.urlStem}/delete";
                        final payload = jsonEncode({'crn': crn, 'uid': uid});
                        final response = http.post(url,
                            headers: {'Content-Type': 'application/json'},
                            body: payload);
                        updateClasses();
                      }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
