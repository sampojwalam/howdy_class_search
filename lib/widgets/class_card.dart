import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/counter.dart' as counter;

class ClassCard extends StatelessWidget {
  final String id;
  final String crn;
  final String title;
  final String instructor;
  final String capacity;
  final String rem;
  Function updateClasses;

  ClassCard(this.id, this.crn, this.title, this.instructor, this.capacity,
      this.rem, this.updateClasses) {
    counter.incrementable++;
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (int.parse(rem) < 1) {
      statusColor = Colors.red;
    } else if (int.parse(rem) < 5) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }
    return Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            height: 130.0,
            width: 15.0,
            decoration: BoxDecoration(
                color: statusColor, //Change dynamically!!!!
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                )),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 30.0),
              height: 130.0,
              decoration: BoxDecoration(
                color: Color(0xFFF9F1F1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Course name: " + title),
                    Text("CRN: " + crn),
                    Text("Instructor: " + instructor),
                    Text("Capacity: " + capacity),
                    Text("Spots Remaining: " + rem),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            height: 130.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: Color(0xFFF9F1F1),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        final uid = FirebaseAuth.instance.currentUser.uid;
                        //const url = "https://cap1.herpin.net:5000/add";
                        const url = "https://81dd869ddae3.ngrok.io/delete";
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
