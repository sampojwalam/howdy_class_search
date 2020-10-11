import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/globals.dart' as globals;

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
    globals.incrementable++;
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
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          letterSpacing: 1.5),
                    ),
                    Text("Instructor: " + instructor),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("CRN: " + crn),
                            Text("Capacity: " + capacity),
                            Text("Spots Remaining: " + rem),
                          ],
                        ),
                        PieChartView(),
                      ],
                    ),
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

class PieChartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(193, 214, 233, 1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                spreadRadius: -10,
                blurRadius: 17,
                offset: Offset(-5, -5),
                color: Colors.white,
              ),
              BoxShadow(
                spreadRadius: -2,
                blurRadius: 10,
                offset: Offset(7, 7),
                color: Color.fromRGBO(146, 182, 216, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PieChart extends CustomPainter {
  final int remaining;
  final int capacity;
  final double width;

  PieChart({this.capacity, this.remaining, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double raidus = min(size.width / 2, size.height / 2);

    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width / 2;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
