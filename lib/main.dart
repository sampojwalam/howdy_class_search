import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import './screens/classes_screen.dart';
import './screens/add_class.dart';
import './screens/auth_screen.dart';

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
            print(snapshot.error);
            return Container();
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //token found
                  return ClassesScreen();
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
