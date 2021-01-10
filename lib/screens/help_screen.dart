import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  static const routeName = "/help-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
      ),
      body: Text("Contact caleb.herpin@gmail.com for help."),
    );
  }
}
