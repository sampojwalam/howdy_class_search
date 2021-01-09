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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _crnController = TextEditingController();
  final _subjController = TextEditingController();
  final _crseController = TextEditingController();
  final _genSearchController = TextEditingController();
  var courseSuggestions = [];
  Timer myTimer;
  String myStr;
  double screenWidth = -1;

  void handleError(strJson) {
    String msg = "Uknown error";
    try {
      msg = json.decode(strJson)["error"]["msg"];
    } catch (_) {}

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).errorColor,
      content: Text("ERROR: " + msg),
    ));
    return;
  }

  Future myPost(url, payload) async {
    var response = await http.post(
      url,
      body: payload,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      print(response.body);
      handleError(response.body);
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
          final uid = FirebaseAuth.instance.currentUser.uid;
          final payload = jsonEncode({
            'subj': _subjController.text.toString(),
            'crse': _crseController.text.toString(),
            'uid': uid,
            'query': value
          });
          print("General querey: " + payload);
          fullQuerySearch(payload);
        },
      ),
    );
    return rvalue;
  }

  Container getClassBox(var classDict) {
    Container rvalue = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), border: Border.all(width: 2)),
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
                                  'uid': uid
                                });
                                final response2 = await http.post(url2,
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: payload2);
                                //print(response.body);
                                setState(() {
                                  classDict = json.decode(response2.body);
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

                              final url2 = "${globals.urlStem}/fullQuery";
                              final payload2 = jsonEncode({
                                'subj': _subjController.text.toString(),
                                'crse': _crseController.text.toString(),
                                'uid': uid
                              });
                              final response2 = await http.post(url2,
                                  headers: {'Content-Type': 'application/json'},
                                  body: payload2);
                              //print(response.body);
                              setState(() {
                                classDict = json.decode(response2.body);
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
                              'uid': uid
                            });
                            final response2 = await http.post(url2,
                                headers: {'Content-Type': 'application/json'},
                                body: payload2);
                            //print(response.body);
                            setState(() {
                              classDict = json.decode(response2.body);
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
                            'uid': uid
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
            getPadding("CRN", _crnController),
            SizedBox(height: 15),
            getPadding("Subject", _subjController),
            SizedBox(height: 15),
            getPadding("Crse", _crseController),
            SizedBox(height: 15),
            getPadding("General Search", _genSearchController),
            SizedBox(height: 15),
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
                    child: getClassBox(courseSuggestions[index]));
              },
            ),
          ],
        ),
      ),
    );
  }
}
