import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:howdy_class_search/screens/auth_screen.dart';

import '../screens/classes_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF400000),
                  Color(0xFF900000),
                ],
              ),
            ),
            height: MediaQuery.of(context).viewPadding.top + 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Howdy Class Search",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () =>
                Navigator.of(context).pushNamed(ClassesScreen.routeName),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Logout"),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
