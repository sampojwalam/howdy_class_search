import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/globals.dart' as globals;
import './auth_screen.dart';

class AddClassScreen extends StatefulWidget {
  static const routeName = '/add-class';

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _crnController = TextEditingController();
  final _subjController = TextEditingController();
  final _crseController = TextEditingController();
  final _genSearchController = TextEditingController();
  var courseSuggestions = [];
  bool searchNonEmptyOnly = false;
  Timer myTimer;
  String myStr;
  double screenWidth = -1;

  void handleError(strJson) {
    String msg = "Unknown error occured. Please try again.";
    try {
      msg = json.decode(strJson)["error"]["msg"];
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).errorColor,
        content: Text("ERROR: " + msg),
      ),
    );
  }

  Future myPost(url, payload) async {
    var response;
    try {
      response = await http.post(
        url,
        body: payload,
        headers: {'Content-Type': 'application/json'},
      ).catchError((error) {
        print("OMG ITS AN ERROR HOLY DUCK!");
        handleError(error);
      });
    } catch (_) {
      handleError(response.body);
      return;
    }

    if (response.statusCode != 200) {
      print(response.body);
      handleError(response.body);
      return;
    }
    return response;
  }

  void fullQuerySearch(String payload) {
    final url = "${globals.urlStem}/fullQuery";
    if (myTimer != null) {
      myTimer.cancel();
    }
    if (json.decode(payload)["subj"] == "" &&
        json.decode(payload)["crse"] == "" &&
        json.decode(payload)["query"] == "") {
      setState(() {
        courseSuggestions = [];
      });
    } else {
      myTimer = Timer(Duration(milliseconds: 200), () async {
        print("Timer done! Running full query now!");

        try {
          await myPost(url, payload).then((response) {
            setState(() {
              courseSuggestions = json.decode(response.body);
            });
          });
        } catch (_) {
          print("Error decoding response.");
        }
      });
    }
  }

  Padding getPadding(String title, final controller) {
    Padding rvalue = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      gapPadding: 5.0,
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(20.0),
                      ),
                    ),
                    labelText: title,
                  ),
                  controller: controller,
                  onChanged: (value) async {
                    if (value.trim().isEmpty) {
                      myTimer.cancel();
                      setState(() {
                        courseSuggestions = [];
                      });
                    } else {
                      final uid = FirebaseAuth.instance.currentUser.uid;
                      final payload = jsonEncode({
                        'subj': _subjController.text.trim().toString(),
                        'crse': _crseController.text.trim().toString(),
                        'uid': uid,
                        'query': value.trim(),
                        'open_required': searchNonEmptyOnly.toString(),
                      });
                      print("General querey: " + payload);
                      fullQuerySearch(payload);
                    }
                  },
                ),
              ),
              if (kIsWeb) SizedBox(width: 10),
              if (kIsWeb)
                Text(
                  "Exclude Full Classes: ",
                  style: TextStyle(fontSize: 20),
                ),
              if (kIsWeb)
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    value: searchNonEmptyOnly,
                    onChanged: (newValue) async {
                      setState(() {
                        searchNonEmptyOnly = newValue;
                      });
                      final uid = FirebaseAuth.instance.currentUser.uid;
                      final url2 = "${globals.urlStem}/fullQuery";
                      final payload2 = jsonEncode({
                        'subj': _subjController.text.toString(),
                        'crse': _crseController.text.toString(),
                        'uid': uid,
                        'query': _genSearchController.text.trim().toString(),
                        'open_required': searchNonEmptyOnly.toString(),
                      });

                      final response2 = await http.post(url2,
                          headers: {'Content-Type': 'application/json'},
                          body: payload2);
                      //print(response.body);
                      setState(() {
                        courseSuggestions = json.decode(response2.body);
                      });
                    },
                  ),
                )
            ],
          ),
          if (!kIsWeb)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Exclude Full Classes: ",
                  style: TextStyle(fontSize: 16),
                ),
                Checkbox(
                  value: searchNonEmptyOnly,
                  onChanged: (newValue) {
                    setState(() {
                      searchNonEmptyOnly = newValue;
                    });
                  },
                )
              ],
            )
        ],
      ),
    );
    return rvalue;
  }

  Container getClassBox(var classDict) {
    var rem = int.parse(classDict["Rem"]);
    Color statusColor;
    if (rem < 1) {
      statusColor = Colors.red;
    } else if (rem < 6) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }
    Container rvalue = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          width: 2,
        ),
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: screenWidth < 500 ? 265 : null,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Title: " + classDict["Title"],
                style: TextStyle(
                  fontSize: 20,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              Row(
                children: [
                  Text("Course: " + classDict["Subj"]),
                  Text(" - " +
                      classDict["Crse"] +
                      "   Section: " +
                      classDict["Sec"]),
                  SizedBox(width: 5),
                ],
              ),
              Text("CRN: " + classDict["CRN"]),
              Text(
                "${classDict["Rem"]} of ${classDict["Cap"]} spots remaining",
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Instructor: " + classDict["Instructor"]),
            ]),
          ),
          SizedBox(width: 5),
          Column(
            children: [
              screenWidth < 500
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: classDict["added"] == 'true'
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: classDict["added"] == 'true'
                            ? null
                            : () async {
                                final crn = classDict["CRN"];
                                final uid =
                                    FirebaseAuth.instance.currentUser.uid;
                                //const url = "https://cap1.herpin.net:5000/add";
                                final url = "${globals.urlStem}/add";
                                final payload =
                                    jsonEncode({'crn': crn, 'uid': uid});
                                final response = await http.post(url,
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: payload);
                                print(response.body);

                                final url2 = "${globals.urlStem}/fullQuery";
                                final payload2 = jsonEncode({
                                  'subj': _subjController.text.toString(),
                                  'crse': _crseController.text.toString(),
                                  'uid': uid,
                                  'query': _genSearchController.text
                                      .trim()
                                      .toString(),
                                  'open_required':
                                      searchNonEmptyOnly.toString(),
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
                        icon: classDict["added"] == 'true'
                            ? Icon(Icons.check)
                            : Icon(Icons.add),
                      ),
                    )
                  : RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Theme.of(context).primaryColor,
                      onPressed: classDict["added"] == 'true'
                          ? null
                          : () async {
                              final crn = classDict["CRN"];
                              final uid = FirebaseAuth.instance.currentUser.uid;
                              //const url = "https://cap1.herpin.net:5000/add";
                              final url = "${globals.urlStem}/add";
                              final payload =
                                  jsonEncode({'crn': crn, 'uid': uid});
                              final response = await http.post(url,
                                  headers: {'Content-Type': 'application/json'},
                                  body: payload);
                              print(response.body);

                              if (response.statusCode != 200) {
                                handleError(response.body);
                              }

                              final url2 = "${globals.urlStem}/fullQuery";
                              final payload2 = jsonEncode({
                                'subj': _subjController.text.toString(),
                                'crse': _crseController.text.toString(),
                                'uid': uid,
                                'query':
                                    _genSearchController.text.trim().toString(),
                                'open_required': searchNonEmptyOnly.toString(),
                              });
                              final response2 = await http.post(url2,
                                  headers: {'Content-Type': 'application/json'},
                                  body: payload2);
                              //print(response.body);
                              if (response2.statusCode != 200) {
                                handleError(response2.body);
                              }
                              setState(() {
                                courseSuggestions = json.decode(response2.body);
                              });
                              //Navigator.of(context).pop();
                            },
                      icon: classDict["added"] == 'true'
                          ? Icon(Icons.check)
                          : Icon(Icons.add),
                      label: classDict["added"] == 'true'
                          ? Text("Added")
                          : Text("Add Class"),
                    ),
              SizedBox(height: 10),
              if (classDict["added"] == 'true')
                screenWidth < 500
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.red,
                        ),
                        child: IconButton(
                          // shape: RoundedRectangleBorder(
                          //   borderRadius:
                          //       BorderRadius.circular(10.0),
                          // ),
                          color: Colors.white,
                          onPressed: () async {
                            final crn = classDict["CRN"];
                            final uid = FirebaseAuth.instance.currentUser.uid;
                            //const url = "https://cap1.herpin.net:5000/add";
                            final url = "${globals.urlStem}/delete";
                            final payload =
                                jsonEncode({'crn': crn, 'uid': uid});
                            final response = await http.post(url,
                                headers: {'Content-Type': 'application/json'},
                                body: payload);

                            final url2 = "${globals.urlStem}/fullQuery";
                            final payload2 = jsonEncode({
                              'subj': _subjController.text.toString(),
                              'crse': _crseController.text.toString(),
                              'uid': uid,
                              'query':
                                  _genSearchController.text.trim().toString(),
                              'open_required': searchNonEmptyOnly.toString(),
                            });
                            final response2 = await http.post(url2,
                                headers: {'Content-Type': 'application/json'},
                                body: payload2);
                            //print(response.body);
                            setState(() {
                              courseSuggestions = json.decode(response2.body);
                            });
                            //Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.delete),
                        ),
                      )
                    : RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.red,
                        onPressed: () async {
                          final crn = classDict["CRN"];
                          final uid = FirebaseAuth.instance.currentUser.uid;
                          //const url = "https://cap1.herpin.net:5000/add";
                          final url = "${globals.urlStem}/delete";
                          final payload = jsonEncode({'crn': crn, 'uid': uid});
                          final response = await http.post(url,
                              headers: {'Content-Type': 'application/json'},
                              body: payload);

                          final url2 = "${globals.urlStem}/fullQuery";
                          final payload2 = jsonEncode({
                            'subj': _subjController.text.toString(),
                            'crse': _crseController.text.toString(),
                            'uid': uid,
                            'query':
                                _genSearchController.text.trim().toString(),
                            'open_required': searchNonEmptyOnly.toString(),
                          });
                          final response2 = await http.post(url2,
                              headers: {'Content-Type': 'application/json'},
                              body: payload2);
                          //print(response.body);
                          setState(() {
                            courseSuggestions = json.decode(response2.body);
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
    );
    return rvalue;
  }

  @override
  Widget build(BuildContext context) {
    this.screenWidth = MediaQuery.of(context).size.width;

    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
    }

    if (courseSuggestions.isNotEmpty) {
      print("Course Title" + courseSuggestions[0]["Title"].toString());
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Add a New Class"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: globals.tamuGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // getPadding("CRN", _crnController),
            // SizedBox(height: 15),
            // getPadding("Subject", _subjController),
            // SizedBox(height: 15),
            // getPadding("Crse", _crseController),
            SizedBox(height: 15),
            getPadding("Search Courses", _genSearchController),
            SizedBox(height: 10),
            Text(
              'Search TAMU courses by Title, CRN, Instructor, or Subject/Course. For example, you can search "Chemistry", "27547", "Andrew Tripp", "POLS 200", or "PHYS" to find the relevant classes!',
              style: TextStyle(
                fontSize: kIsWeb ? 18 : 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0),
            // RaisedButton.icon(
            //   onPressed: () async {
            //     final crn = _crnController.text.trim();

            //     if (crn.length != 5) {
            //       _scaffoldKey.currentState.showSnackBar(SnackBar(
            //         backgroundColor: Theme.of(context).errorColor,
            //         content: Text("Invalid CRN. Please enter a valid CRN."),
            //       ));
            //       return;
            //     }

            //     final uid = FirebaseAuth.instance.currentUser.uid;
            //     //const url = "https://cap1.herpin.net:5000/add";
            //     final url = "${globals.urlStem}/add";
            //     final payload = jsonEncode({'crn': crn, 'uid': uid});
            //     final response = await myPost(url, payload);
            //     Navigator.of(context).pop();
            //   },
            //   icon: Icon(
            //     Icons.add,
            //     color: Colors.white,
            //   ),
            //   label: Text(
            //     "Add Class",
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   elevation: 0,
            //   color: Theme.of(context).primaryColor,
            //   //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            // ),
            SizedBox(height: 15),
            if (courseSuggestions.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: courseSuggestions.length == 50
                        ? Text("Showing first 50 results:")
                        : Text("${courseSuggestions.length} results found:"),
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
                  child: getClassBox(courseSuggestions[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
