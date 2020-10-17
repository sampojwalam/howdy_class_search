import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_client/http_client.dart';

import '../widgets/app_drawer.dart';
import '../widgets/class_card.dart';
import '../screens/add_class.dart';
import '../models/globals.dart' as globals;

class ClassesScreen extends StatefulWidget {
  static const routeName = '/classes-screen';
  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  var top = 0.0;

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
      drawer: AppDrawer(),
      body: CustomScrollView(
        slivers: [
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
            flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
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
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xFF200000),
                              Color(0xFF800000),
                            ]),
                        image: DecorationImage(
                            image: AssetImage("assets/images/tamu_logo.png")),
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
                      for (var i = 0; i < snapshot.data.length; i++) {
                        if (snapshot.data[i]["valid"] == "true") {
                          classCards.add(
                            ClassCard(
                              snapshot.data[i]["id"].toString(),
                              snapshot.data[i]["CRN"].toString(),
                              snapshot.data[i]["Title"].toString(),
                              snapshot.data[i]["Instructor"].toString(),
                              snapshot.data[i]["Cap"].toString(),
                              snapshot.data[i]["Rem"].toString(),
                              refresh,
                            ),
                          );
                        } else {
                          classCards.add(
                            ClassCard(
                              snapshot.data[i]["id"].toString(),
                              snapshot.data[i]["userCRN"].toString(),
                              snapshot.data[i]["error"].toString(),
                              "N/A",
                              "N/A",
                              "0",
                              refresh,
                            ),
                          );
                        }
                      }
                      return Column(children: classCards);
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
