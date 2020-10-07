import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import './widgets/class_card.dart';
import './screens/add_class.dart';
import './screens/auth_screen.dart';
import './models/class.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid 19',
      theme: ThemeData(
        primaryColor: Color(0xFF500000),
        scaffoldBackgroundColor: Color(0xFFFEFEFE),
        fontFamily: "Poppins",
        textTheme: TextTheme(
          bodyText2: TextStyle(
            color: Color(0xFF4B4B4B),
          ),
        ),
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return null;
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //token found
                  return HomeScreen();
                }
                return AuthScreen();
              },
            );
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return null;
        },
      ),
      routes: {
        //key (route name) : value (builder)
        AddClassScreen.routeName: (ctx) => AddClassScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var top = 0.0;

  //Testing json -> class object conversion
  Future<List<dynamic>> getJson(BuildContext ctx) async {
    final classesJson =
        await DefaultAssetBundle.of(ctx).loadString("assets/data/classes.json");
    final classes = json.decode(classesJson);
    return classes;
  }

  @override
  Widget build(BuildContext context) {
    final classesList = getJson(context);
    //Testing json -> class object conversion

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text(
          "Add a class",
          style: TextStyle(fontFamily: "Poppins"),
        ),
        onPressed: () =>
            Navigator.of(context).pushNamed(AddClassScreen.routeName),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  })
            ],
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              top = constraints.biggest.height;
              return FlexibleSpaceBar(
                title: Text(top > 150 ? "" : "Howdy Class Search"),
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
                    if (snapshot.hasData) {
                      List<Widget> classCards = [];
                      for (var i = 0; i < snapshot.data.length; i++) {
                        classCards.add(
                          ClassCard(
                            snapshot.data[i]["CRN"],
                            snapshot.data[i]["Title"],
                            snapshot.data[i]["Instructor"],
                            snapshot.data[i]["Cap"],
                            snapshot.data[i]["Rem"],
                          ),
                        );
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
