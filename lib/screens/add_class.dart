import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/globals.dart' as globals;
import './auth_screen.dart';

class AddClassScreen extends StatefulWidget {
  static const routeName = '/add-class';

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _crnController = TextEditingController();
  final _subjController = TextEditingController();
  final _crseController = TextEditingController();
  var courseSuggestions = [];
  Timer myTimer;
  String myStr;

  void fullQuerySearch(String payload) {
    final url = "${globals.urlStem}/fullQuery";
    if (myTimer != null) {
      myTimer.cancel();
    }
    if (json.decode(payload)["subj"] == "" &&
        json.decode(payload)["crse"] == "") {
      setState(() {
        courseSuggestions = [];
      });
    } else {
      myTimer = Timer(Duration(milliseconds: 200), () async {
        print("Timer done! Running full query now!");

        await http
            .post(url,
                headers: {'Content-Type': 'application/json'}, body: payload)
            .then((response) {
          setState(() {
            courseSuggestions = json.decode(response.body);
          });
        });
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
    }

    if (courseSuggestions.isNotEmpty) {
      print("Course Title" + courseSuggestions[0]["Title"].toString());
    }

    var linearGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        // Color(0xFF400000),
        // Color(0xFF900000),
        Colors.green,
        Colors.lightGreen,
      ],
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Add a New Class"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: linearGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
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
                onSubmitted: (inputCRN) async {
                  final crn = inputCRN.trim();
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
                      headers: {'Content-Type': 'application/json'},
                      body: payload);
                  Navigator.of(context).pop();
                },
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
                    headers: {'Content-Type': 'application/json'},
                    body: payload);
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
            ),
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
                  labelText: "Subject",
                ),
                controller: _subjController,
                onChanged: (value) async {
                  final uid = FirebaseAuth.instance.currentUser.uid;

                  final payload = jsonEncode({
                    'subj': value,
                    'crse': _crseController.text.toString(),
                    'uid': uid
                  });

                  fullQuerySearch(payload);

                  //print(courseSuggestions);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    gapPadding: 5.0,
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                  ),
                  labelText: "Course",
                ),
                controller: _crseController,
                onChanged: (value) async {
                  final uid = FirebaseAuth.instance.currentUser.uid;
                  final payload = jsonEncode({
                    'subj': _subjController.text.toString(),
                    'crse': value,
                    'uid': uid
                  });
                  fullQuerySearch(payload);
                },
              ),
            ),
            SizedBox(height: 15),
            if (courseSuggestions.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text("${courseSuggestions.length} results found:"),
                  ),
                ],
              ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              //scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: courseSuggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 2)),
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: screenWidth < 500 ? 265 : null,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Title: " + courseSuggestions[index]["Title"],
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                                Row(
                                  children: [
                                    Text("Course: " +
                                        courseSuggestions[index]["Subj"]),
                                    Text(" - " +
                                        courseSuggestions[index]["Crse"] +
                                        "   Section: " +
                                        courseSuggestions[index]["Sec"]),
                                    SizedBox(width: 5),
                                  ],
                                ),
                                Text("CRN: " + courseSuggestions[index]["CRN"]),
                                Text("Instructor: " +
                                    courseSuggestions[index]["Instructor"]),
                              ]),
                        ),
                        SizedBox(width: 5),
                        Column(
                          children: [
                            screenWidth < 500
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: courseSuggestions[index]
                                                  ["added"] ==
                                              'true'
                                          ? Colors.grey
                                          : Theme.of(context).primaryColor,
                                    ),
                                    child: IconButton(
                                      color: Colors.white,
                                      onPressed: courseSuggestions[index]
                                                  ["added"] ==
                                              'true'
                                          ? null
                                          : () async {
                                              final crn =
                                                  courseSuggestions[index]
                                                      ["CRN"];
                                              final uid = FirebaseAuth
                                                  .instance.currentUser.uid;
                                              //const url = "https://cap1.herpin.net:5000/add";
                                              final url =
                                                  "${globals.urlStem}/add";
                                              final payload = jsonEncode(
                                                  {'crn': crn, 'uid': uid});
                                              final response = await http.post(
                                                  url,
                                                  headers: {
                                                    'Content-Type':
                                                        'application/json'
                                                  },
                                                  body: payload);
                                              print(response.body);

                                              final url2 =
                                                  "${globals.urlStem}/fullQuery";
                                              final payload2 = jsonEncode({
                                                'subj': _subjController.text
                                                    .toString(),
                                                'crse': _crseController.text
                                                    .toString(),
                                                'uid': uid
                                              });
                                              final response2 = await http.post(
                                                  url2,
                                                  headers: {
                                                    'Content-Type':
                                                        'application/json'
                                                  },
                                                  body: payload2);
                                              //print(response.body);
                                              setState(() {
                                                courseSuggestions =
                                                    json.decode(response2.body);
                                              });
                                              //Navigator.of(context).pop();
                                            },
                                      icon: courseSuggestions[index]["added"] ==
                                              'true'
                                          ? Icon(Icons.check)
                                          : Icon(Icons.add),
                                    ),
                                  )
                                : RaisedButton.icon(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: courseSuggestions[index]
                                                ["added"] ==
                                            'true'
                                        ? null
                                        : () async {
                                            final crn =
                                                courseSuggestions[index]["CRN"];
                                            final uid = FirebaseAuth
                                                .instance.currentUser.uid;
                                            //const url = "https://cap1.herpin.net:5000/add";
                                            final url =
                                                "${globals.urlStem}/add";
                                            final payload = jsonEncode(
                                                {'crn': crn, 'uid': uid});
                                            final response = await http.post(
                                                url,
                                                headers: {
                                                  'Content-Type':
                                                      'application/json'
                                                },
                                                body: payload);
                                            print(response.body);

                                            final url2 =
                                                "${globals.urlStem}/fullQuery";
                                            final payload2 = jsonEncode({
                                              'subj': _subjController.text
                                                  .toString(),
                                              'crse': _crseController.text
                                                  .toString(),
                                              'uid': uid
                                            });
                                            final response2 = await http.post(
                                                url2,
                                                headers: {
                                                  'Content-Type':
                                                      'application/json'
                                                },
                                                body: payload2);
                                            //print(response.body);
                                            setState(() {
                                              courseSuggestions =
                                                  json.decode(response2.body);
                                            });
                                            //Navigator.of(context).pop();
                                          },
                                    icon: courseSuggestions[index]["added"] ==
                                            'true'
                                        ? Icon(Icons.check)
                                        : Icon(Icons.add),
                                    label: courseSuggestions[index]["added"] ==
                                            'true'
                                        ? Text("Added")
                                        : Text("Add Class"),
                                  ),
                            SizedBox(height: 10),
                            if (courseSuggestions[index]["added"] == 'true')
                              screenWidth < 500
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Colors.red,
                                      ),
                                      child: IconButton(
                                        // shape: RoundedRectangleBorder(
                                        //   borderRadius:
                                        //       BorderRadius.circular(10.0),
                                        // ),
                                        color: Colors.white,
                                        onPressed: () async {
                                          final crn =
                                              courseSuggestions[index]["CRN"];
                                          final uid = FirebaseAuth
                                              .instance.currentUser.uid;
                                          //const url = "https://cap1.herpin.net:5000/add";
                                          final url =
                                              "${globals.urlStem}/delete";
                                          final payload = jsonEncode(
                                              {'crn': crn, 'uid': uid});
                                          final response = await http.post(url,
                                              headers: {
                                                'Content-Type':
                                                    'application/json'
                                              },
                                              body: payload);

                                          final url2 =
                                              "${globals.urlStem}/fullQuery";
                                          final payload2 = jsonEncode({
                                            'subj':
                                                _subjController.text.toString(),
                                            'crse':
                                                _crseController.text.toString(),
                                            'uid': uid
                                          });
                                          final response2 = await http.post(
                                              url2,
                                              headers: {
                                                'Content-Type':
                                                    'application/json'
                                              },
                                              body: payload2);
                                          //print(response.body);
                                          setState(() {
                                            courseSuggestions =
                                                json.decode(response2.body);
                                          });
                                          //Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
                                    )
                                  : RaisedButton.icon(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      color: Colors.red,
                                      onPressed: () async {
                                        final crn =
                                            courseSuggestions[index]["CRN"];
                                        final uid = FirebaseAuth
                                            .instance.currentUser.uid;
                                        //const url = "https://cap1.herpin.net:5000/add";
                                        final url = "${globals.urlStem}/delete";
                                        final payload = jsonEncode(
                                            {'crn': crn, 'uid': uid});
                                        final response = await http.post(url,
                                            headers: {
                                              'Content-Type': 'application/json'
                                            },
                                            body: payload);

                                        final url2 =
                                            "${globals.urlStem}/fullQuery";
                                        final payload2 = jsonEncode({
                                          'subj':
                                              _subjController.text.toString(),
                                          'crse':
                                              _crseController.text.toString(),
                                          'uid': uid
                                        });
                                        final response2 = await http.post(url2,
                                            headers: {
                                              'Content-Type': 'application/json'
                                            },
                                            body: payload2);
                                        //print(response.body);
                                        setState(() {
                                          courseSuggestions =
                                              json.decode(response2.body);
                                        });
                                        //Navigator.of(context).pop();
                                      },
                                      icon: Icon(Icons.delete),
                                      label: Text("Remove"),
                                    )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
