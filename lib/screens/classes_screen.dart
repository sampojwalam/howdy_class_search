import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:howdy_class_search/screens/help_screen.dart';
import 'package:howdy_class_search/screens/schedule_screen.dart';
import 'package:howdy_class_search/screens/settings_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http_client/http_client.dart';

import './auth_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/class_card.dart';
import '../widgets/invalid_class_card.dart';
import './add_class.dart';
import '../models/globals.dart' as globals;

class ClassesScreen extends StatefulWidget {
  static const routeName = '/classes-screen';
  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  var top = 0.0;
  var classesNum;

  //Testing json -> class object conversion
  Future<List<dynamic>> getJson(BuildContext ctx) async {
    //final classesJson = await DefaultAssetBundle.of(ctx).loadString("assets/data/classes.json");
    final uid = FirebaseAuth.instance.currentUser.uid;

    //final url = "http://cap1.herpin.net:5000/current?uid=$uid";
    final url = "${globals.urlStem}/current?uid=$uid";
    final classesJson = await http.get(url);
    final classes = json.decode(classesJson.body);
    return classes;
  }

  @override
  Widget build(BuildContext context) {
    var classesList = getJson(context);
    //Testing json -> class object conversion

    void refresh() {
      classesList = getJson(context);
      setState(() {});
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text(
          "Add a class",
          style: TextStyle(fontFamily: "Poppins"),
        ),
        onPressed: () => Navigator.of(context)
            .pushNamed(AddClassScreen.routeName)
            .then((value) {
          setState(() {});
        }),
      ),
      drawer: kIsWeb ? null : AppDrawer(),
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
                        color: Colors.blue,
                      ),
                      Container(
                        width: 95,
                        height: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.home,
                            color: Colors.blue,
                            size: 40,
                          ),
                          onPressed: () {
                            //do nothing.
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
                            Navigator.of(context)
                                .pushReplacementNamed(ScheduleScreen.routeName);
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
                            Icons.settings,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(SettingsScreen.routeName);
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
                            Navigator.of(context)
                                .pushReplacementNamed(HelpScreen.routeName);
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
            child: CustomScrollView(
              slivers: [
                if (!kIsWeb)
                  SliverAppBar(
                    // leading: IconButton(
                    //     icon: Icon(Icons.menu),
                    //     onPressed: () {
                    //       print("work in progress");
                    //     }),
                    actions: [
                      IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {});
                          }),
                    ],
                    expandedHeight: 350,
                    pinned: true,
                    flexibleSpace: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      top = constraints.biggest.height;
                      return FlexibleSpaceBar(
                        title: Text(
                          top > 150 ? "" : "Howdy Class Search",
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: ClipPath(
                            clipper: MyClipper(),
                            child: Container(
                              height: 350,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: globals.tamuGradient,
                                image: DecorationImage(
                                    image:
                                        AssetImage("assets/images/logo.png")),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),

                      //Testing json -> class object conversion
                      child: FutureBuilder(
                        future: classesList,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                          }
                          if (snapshot.hasData) {
                            List<Widget> classCards = [];
                            // classCards.add(
                            //   Text(
                            //       "Currently tracking ${snapshot.data.length} classes."),
                            // );
                            classesNum = snapshot.data.length;
                            for (var i = 0; i < snapshot.data.length; i++) {
                              if (snapshot.data[i]["valid"] == "true") {
                                classCards.add(
                                  ClassCard(
                                    snapshot.data[i]["id"].toString(),
                                    snapshot.data[i]["CRN"].toString(),
                                    snapshot.data[i]["Title"].toString(),
                                    snapshot.data[i]["Subj"].toString(),
                                    snapshot.data[i]["Crse"].toString(),
                                    snapshot.data[i]["Sec"].toString(),
                                    snapshot.data[i]["Instructor"].toString(),
                                    snapshot.data[i]["Cap"].toString(),
                                    snapshot.data[i]["Rem"].toString(),
                                    refresh,
                                  ),
                                );
                              } else {
                                classCards.add(
                                  InvalidClassCard(
                                    snapshot.data[i]["userCRN"].toString(),
                                    refresh,
                                  ),
                                );
                              }
                            }
                            return Column(
                                children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Currently tracking ${snapshot.data.length} classes.",
                                            style: TextStyle(
                                              fontSize: kIsWeb ? 20 : 18,
                                            ),
                                          ),
                                          IconButton(
                                              icon: Icon(
                                                Icons.refresh,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              onPressed: () {
                                                setState(() {});
                                              }),
                                        ],
                                      ),
                                      if (kIsWeb) SizedBox(height: 5),
                                    ] +
                                    classCards);
                          } else {
                            return Column(children: [
                              SizedBox(height: 20),
                              CircularProgressIndicator()
                            ]);
                          }
                        },
                      ),
                    )
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
