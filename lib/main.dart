import 'package:flutter/material.dart';

import './screens/add_class.dart';
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
      home: HomeScreen(),
      routes: {
        //key (route name) : value (builder)
        AddClassScreen.routeName: (ctx) => AddClassScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          ClipPath(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 30.0),
                    height: 130.0,
                    width: 15.0,
                    decoration: BoxDecoration(
                        color: Colors.green,
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
                          )),
                    ),
                  ),
                ],
              )
            ]),
          )
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
