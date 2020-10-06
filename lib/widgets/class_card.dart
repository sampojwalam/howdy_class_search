import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String crn;
  final String title;
  final String instructor;
  final String capacity;
  final String rem;

  ClassCard(this.crn, this.title, this.instructor, this.capacity, this.rem);

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
    return Row(
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
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
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
              )),
        ),
      ],
    );
  }
}
