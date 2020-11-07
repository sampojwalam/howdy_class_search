import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/globals.dart' as globals;
import './auth_screen.dart';
import './classes_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications;
  bool _phoneNotifications;
  bool _pushNotifications;
  String _email;
  String _phone;
  TextEditingController _emailController;
  TextEditingController _phoneController;
  bool _changesToSave = false;
  var settings;

  final _crnController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<List<dynamic>> getSettings(BuildContext ctx) async {
    //final classesJson = await DefaultAssetBundle.of(ctx).loadString("assets/data/classes.json");
    final uid = FirebaseAuth.instance.currentUser.uid;
    //print(uid);

    //final url = "http://cap1.herpin.net:5000/current?uid=$uid";
    final url = "${globals.urlStem}/user?uid=$uid";
    final settingsJson = await http.get(url);
    print(settingsJson);
    final settings = json.decode(settingsJson.body);
    //print(settings);
    return settings;
  }

  void save() async {
    final uid = FirebaseAuth.instance.currentUser.uid;

    //const url = "https://cap1.herpin.net:5000/add";
    final url = "${globals.urlStem}/alterUser";
    if (_emailNotifications == false) {
      _email = "";
    } else {
      _email = _emailController.text.trim();
    }
    if (_phoneNotifications == false) {
      _phone = "";
    } else {
      _phone = _phoneController.text.trim();
    }
    final payload = jsonEncode({
      'uid': uid,
      'email': _email,
      'phone': _phone,
      'name': '',
      'notification': _pushNotifications.toString()
    });
    print(payload);
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: payload);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    if (settings == null) {
      settings = getSettings(context);
    }
    return Scaffold(
      key: _scaffoldKey,

      //drawer: AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_changesToSave) {
                showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Text("Would you like to save your changes?"),
                    actions: [
                      TextButton.icon(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(ClassesScreen.routeName);
                        },
                        label: Text(
                          "Discard",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.save, color: Colors.blue),
                        onPressed: () {
                          if (_phoneController.text.trim().length == 10) {
                            save();
                            Navigator.of(context)
                                .pushReplacementNamed(ClassesScreen.routeName);
                          } else {
                            Navigator.of(context).pop();
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Phone number must be 10 digits long, with no hypens."),
                              ),
                            );
                          }
                        },
                        label: Text(
                          "Save",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.of(context)
                    .pushReplacementNamed(ClassesScreen.routeName);
              }
            }),
        title: Text("Settings"),
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
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: _changesToSave
                  ? () {
                      if (_phoneController.text.trim().length == 10) {
                        save();
                        setState(() {
                          _changesToSave = false;
                          settings = null;
                        });
                      } else {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Phone number must be 10 digits long, with no hypens."),
                          ),
                        );
                      }
                    }
                  : null)
        ],
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Logged in as: " +
                      FirebaseAuth.instance.currentUser.email),
                  SizedBox(height: 10),
                  FutureBuilder(
                    future: settings,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (!snapshot.hasData || snapshot.hasError) {
                        print(snapshot.error);
                        print(snapshot.connectionState);
                        return Text(
                            "Cannot connect to server. Please check your internet and try again!");
                      } else {
                        //print(snapshot.data);
                        if (_pushNotifications == null) {
                          //print(snapshot.data[0]);
                          _pushNotifications =
                              snapshot.data[0]["enableNotification"];
                        }
                        if (_email == null) {
                          _email = snapshot.data[0]["emailAddress"];
                          if (_email == '' || _email == null) {
                            _emailNotifications = false;
                          } else {
                            _emailNotifications = true;
                          }
                          _emailController =
                              TextEditingController(text: _email);
                        }
                        if (_phone == null) {
                          _phone = snapshot.data[0]["phoneNumber"];
                          if (_phone == '' || _phone == null) {
                            _phoneNotifications = false;
                          } else {
                            _phoneNotifications = true;
                          }
                          _phoneController =
                              TextEditingController(text: _phone);
                        }
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Enable Push Notifications"),
                                Switch(
                                    value: _pushNotifications,
                                    onChanged: (value) {
                                      _changesToSave = true;
                                      _pushNotifications = value;
                                      setState(() {});
                                    })
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Enable Email Notifications"),
                                Switch(
                                    value: _emailNotifications,
                                    onChanged: (value) {
                                      _changesToSave = true;
                                      _emailNotifications = value;
                                      setState(() {});
                                    })
                              ],
                            ),
                            if (_emailNotifications)
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    gapPadding: 5.0,
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(20.0),
                                    ),
                                  ),
                                  labelText:
                                      "Email Address for Email Notifications",
                                ),
                                controller: _emailController,
                                onChanged: (value) => setState(() {
                                  _changesToSave = true;
                                }),
                              ),

                            //Text Notifications Settings
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Enable Text Notifications"),
                                Switch(
                                    value: _phoneNotifications,
                                    onChanged: (value) {
                                      _changesToSave = true;
                                      _phoneNotifications = value;
                                      setState(() {});
                                    })
                              ],
                            ),
                            if (_phoneNotifications)
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    gapPadding: 5.0,
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(20.0),
                                    ),
                                  ),
                                  labelText:
                                      "Phone Number for Text Notifications",
                                ),
                                controller: _phoneController,
                                onChanged: (value) => setState(() {
                                  _changesToSave = true;
                                }),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        FirebaseAuth.instance.signOut();
                                        Navigator.of(context)
                                            .pushNamed(AuthScreen.routeName);
                                      },
                                      child: Text(
                                        "Logout",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: _changesToSave
                                          ? () {
                                              save();
                                              setState(() {
                                                _changesToSave = false;
                                                settings = null;
                                              });
                                            }
                                          : null,
                                      child: Text(
                                        "Save Changes",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      }
                    },
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
