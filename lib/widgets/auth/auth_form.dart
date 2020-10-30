import 'dart:io';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String phone,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) submitFunction;

  final bool isLoading;

  final void Function() signInwithGoogle;

  AuthForm(this.submitFunction, this.signInwithGoogle, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail;
  String _userPhone = '';
  String _userPass;
  var _logInMode = true;
  var _signInWithGoogle = true;

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus(); //Close keyboard

    if (isValid) {
      _formKey.currentState.save();

      widget.submitFunction(
        _userEmail.trim(),
        _userPhone,
        _userPass,
        _logInMode,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Card(
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Authenticate with Google (Recommended)",
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        //decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      constraints: BoxConstraints(maxWidth: 420),
                      child: OutlineButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        borderSide: BorderSide(color: Colors.grey),
                        onPressed: () {
                          widget.signInwithGoogle();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image:
                                    AssetImage("assets/images/google_logo.png"),
                                height: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Sign in with Google",
                                softWrap: true,
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 18,
                                  color: Colors.black,
                                  //decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            height: 2,
                            width: 50,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "OR",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 25,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            height: 2,
                            width: 50,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign in with Email & Password",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 20,
                            //decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      key: ValueKey("email"),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: false,
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Please Enter a valid email address!';
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email Address'),
                      onSaved: (newValue) {
                        _userEmail = newValue;
                      },
                    ),
                    if (!_logInMode)
                      TextFormField(
                        key: ValueKey("phone"),
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          //implement validation... yikes!
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText:
                                'Phone number (optional) for text notifications'),
                        onSaved: (newValue) {
                          _userPhone = newValue;
                        },
                      ),
                    TextFormField(
                      key: ValueKey("pass"),
                      validator: (value) {
                        if (value.isEmpty || value.length < 7) {
                          return 'Password must be at least 7 characters long!';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (newValue) {
                        _userPass = newValue;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    if (widget.isLoading) CircularProgressIndicator(),
                    if (!widget.isLoading)
                      RaisedButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: _trySubmit,
                        child: Text(
                          _logInMode ? "Login" : "Signup",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if (!widget.isLoading)
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            _logInMode = !_logInMode;
                          });
                        },
                        child: Text(_logInMode
                            ? "Create New Account"
                            : "Log In Instead"),
                        textColor: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
