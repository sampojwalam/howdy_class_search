import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/help_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/auth_screen.dart';
import '../models/globals.dart' as globals;

class ScheduleScreen extends StatelessWidget {
  static const routeName = '/schedule-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: Text("Schedule"),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: globals.tamuGradient,
                ),
              ),
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
                              Navigator.of(context).pushReplacementNamed(
                                  ClassesScreen.routeName);
                            }),
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
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 40,
                          ),
                          onPressed: () {
                            // Navigator.of(context).pushReplacementNamed(routeName)
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  " The schedule screen is currently under construction. Please check back later!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: kIsWeb ? 24 : 18),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
