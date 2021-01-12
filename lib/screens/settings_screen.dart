import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/globals.dart' as globals;
import './auth_screen.dart';
import './classes_screen.dart';
import './schedule_screen.dart';
import './help_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications;
  bool _phoneNotifications;
  String _phone;
  TextEditingController _phoneController;
  bool _changesToSave = false;
  var settings;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<List<dynamic>> getSettings(BuildContext ctx) async {
    //final classesJson = await DefaultAssetBundle.of(ctx).loadString("assets/data/classes.json");
    final uid = FirebaseAuth.instance.currentUser.uid;
    //print(uid);

    //final url = "http://cap1.herpin.net:5000/current?uid=$uid";
    final url = "${globals.urlStem}/user?uid=$uid";
    final settingsJson = await http.get(url);
    print(settingsJson.body);
    final settings = json.decode(settingsJson.body);
    //print(settings);
    return settings;
  }

  void save() async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    final email = FirebaseAuth.instance.currentUser.email;

    //const url = "https://cap1.herpin.net:5000/add";
    final url = "${globals.urlStem}/alterUser";
    if (_phoneNotifications == false) {
      _phone = "";
    } else {
      _phone = _phoneController.text.trim();
    }
    final payload = jsonEncode({
      'uid': uid,
      'email': email,
      'phone': _phone,
      'name': '',
      'notification': _enableNotifications.toString()
    });
    print(payload);
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: payload);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
    }

    if (settings == null) {
      settings = getSettings(context);
    }

    return Scaffold(
      key: _scaffoldKey,

      //drawer: AppDrawer(),
      appBar: kIsWeb
          ? null
          : AppBar(
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
                                Navigator.of(context).pushReplacementNamed(
                                    ClassesScreen.routeName);
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
                                  Navigator.of(context).pushReplacementNamed(
                                      ClassesScreen.routeName);
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
                  gradient: globals.tamuGradient,
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
      body: Row(
        children: [
          if (kIsWeb)
            Container(
              width: 100,
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: 60,
                    child: Image(
                      image: AssetImage("assets/images/logo_icon.png"),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 5),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 70,
                        color: Theme.of(context).primaryColor,
                      ),
                      Container(
                        width: 95,
                        height: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: () {
                            if (_changesToSave) {
                              showDialog(
                                context: context,
                                child: AlertDialog(
                                  title: Text(
                                      "Would you like to save your changes?"),
                                  actions: [
                                    TextButton.icon(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                ClassesScreen.routeName);
                                      },
                                      label: Text(
                                        "Discard",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton.icon(
                                      icon:
                                          Icon(Icons.save, color: Colors.blue),
                                      onPressed: () {
                                        if (_phoneController.text
                                                .trim()
                                                .length ==
                                            10) {
                                          save();
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  ClassesScreen.routeName);
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
                              Navigator.of(context).pushReplacementNamed(
                                  ClassesScreen.routeName);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 70,
                        color: Theme.of(context).primaryColor,
                      ),
                      Container(
                        width: 95,
                        height: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: () {
                            if (_changesToSave) {
                              showDialog(
                                context: context,
                                child: AlertDialog(
                                  title: Text(
                                      "Would you like to save your changes?"),
                                  actions: [
                                    TextButton.icon(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                ScheduleScreen.routeName);
                                      },
                                      label: Text(
                                        "Discard",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton.icon(
                                      icon:
                                          Icon(Icons.save, color: Colors.blue),
                                      onPressed: () {
                                        if (_phoneController.text
                                                .trim()
                                                .length ==
                                            10) {
                                          save();
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  ScheduleScreen.routeName);
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
                              Navigator.of(context).pushReplacementNamed(
                                  ScheduleScreen.routeName);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 70,
                        color: Colors.blue,
                      ),
                      Container(
                        width: 95,
                        height: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.blue,
                            size: 40,
                          ),
                          onPressed: () {
                            //do nothing
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 70,
                        color: Theme.of(context).primaryColor,
                      ),
                      Container(
                        width: 95,
                        height: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.help,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: () {
                            if (_changesToSave) {
                              showDialog(
                                context: context,
                                child: AlertDialog(
                                  title: Text(
                                      "Would you like to save your changes?"),
                                  actions: [
                                    TextButton.icon(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                HelpScreen.routeName);
                                      },
                                      label: Text(
                                        "Discard",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton.icon(
                                      icon:
                                          Icon(Icons.save, color: Colors.blue),
                                      onPressed: () {
                                        if (_phoneController.text
                                                .trim()
                                                .length ==
                                            10) {
                                          save();
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  HelpScreen.routeName);
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
                                  .pushReplacementNamed(HelpScreen.routeName);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 70,
                        color: Theme.of(context).primaryColor,
                      ),
                      Container(
                        width: 95,
                        height: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.of(context)
                                .pushNamed(AuthScreen.routeName);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          Expanded(
            child: Column(
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                              if (_enableNotifications == null) {
                                //print(snapshot.data[0]);
                                _enableNotifications =
                                    snapshot.data[0]["enableNotification"];
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Enable Notifications"),
                                      Switch(
                                          value: _enableNotifications,
                                          onChanged: (value) {
                                            _changesToSave = true;
                                            _enableNotifications = value;
                                            setState(() {});
                                          })
                                    ],
                                  ),
                                  //Text Notifications Settings
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Enable SMS Notification (Unavaliable)"),
                                      Switch(
                                          value: false,
                                          onChanged: (value) {
                                            // _changesToSave = true;
                                            // _phoneNotifications = value;
                                            // setState(() {});
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
                                            color:
                                                Theme.of(context).primaryColor,
                                            onPressed: () {
                                              FirebaseAuth.instance.signOut();
                                              Navigator.of(context).pushNamed(
                                                  AuthScreen.routeName);
                                            },
                                            child: Text(
                                              "Logout",
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                            color:
                                                Theme.of(context).primaryColor,
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
                                              style: TextStyle(
                                                  color: Colors.white),
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
          ),
        ],
      ),
    );
  }
}
