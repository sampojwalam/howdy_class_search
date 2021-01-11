import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:howdy_class_search/screens/verify_email_screen.dart';

import './screens/help_screen.dart';
import './screens/classes_screen.dart';
import './screens/add_class.dart';
import './screens/auth_screen.dart';
import './screens/settings_screen.dart';
import './screens/schedule_screen.dart';
import './models/globals.dart' as globals;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Howdy Class Search',
      theme: ThemeData(
        primaryColor: globals.primaryColor,
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
            return Container();
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            final _auth = FirebaseAuth.instance;
            return StreamBuilder(
              stream: _auth.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //token found
                  HttpOverrides.global = new MyHttpOverrides();
                  final user = _auth.currentUser;
                  if (user.emailVerified) {
                    return ClassesScreen();
                  } else {
                    return VerifyEmailScreen();
                  }
                }
                return AuthScreen();
              },
            );
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Container();
        },
      ),
      routes: {
        //key (route name) : value (builder)
        AddClassScreen.routeName: (ctx) => AddClassScreen(),
        ClassesScreen.routeName: (ctx) => ClassesScreen(),
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        AuthScreen.routeName: (ctx) => AuthScreen(),
        HelpScreen.routeName: (ctx) => HelpScreen(),
        VerifyEmailScreen.routeName: (ctx) => VerifyEmailScreen(),
        ScheduleScreen.routeName: (ctx) => ScheduleScreen(),
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
