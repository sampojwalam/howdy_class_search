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

  AuthForm(this.submitFunction, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail;
  String _userPhone = '';
  String _userPass;
  var _logInMode = true;

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
                      child: Text(
                          _logInMode ? "Create New Account" : "Log In Instead"),
                      textColor: Theme.of(context).primaryColor,
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
