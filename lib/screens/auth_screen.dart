import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:howdy_class_search/screens/classes_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

import '../models/globals.dart' as globals;
import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  var _isLoading = false;

  void _signInWithGoogle() async {
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');

      final uid = currentUser.uid;
      final email = currentUser.email;
      final phone =
          currentUser.phoneNumber == null ? '' : currentUser.phoneNumber;

      final url = "${globals.urlStem}/addUser";
      final payload = jsonEncode({
        'uid': uid,
        'email': email,
        'phone': phone,
        'name': '',
        'notification': '1'
      });
      final response = await http
          .post(url,
              headers: {'Content-Type': 'application/json'}, body: payload)
          .catchError((error) {
        print("User exists. Logging in.");
      });

      final urlLogin = "${globals.urlStem}/login";
      final responseLogin = await http.get(urlLogin);

      print("is web ?................................ $kIsWeb");

      if (!kIsWeb) {
        FirebaseMessaging fbmInstance = FirebaseMessaging();
        fbmInstance.requestNotificationPermissions();
        fbmInstance.configure(onMessage: (msg) {
          return;
        }, onLaunch: (msg) {
          return;
        }, onResume: (msg) {
          return;
        });
        fbmInstance.subscribeToTopic("$uid");
      }

      Navigator.of(context).pushNamed(ClassesScreen.routeName);
    }
  }

  void _signInWithApple(
      {List<Scope> scopes = const [], BuildContext context}) async {
    // 1. perform the sign-in request
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    print(result);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _auth.signInWithCredential(credential);
        final firebaseUser = authResult.user;
        if (scopes.contains(Scope.fullName)) {
          final displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          await firebaseUser.updateProfile(displayName: displayName);
        }
        final uid = firebaseUser.uid;
        final email = firebaseUser.email;
        final phone =
            firebaseUser.phoneNumber == null ? '' : firebaseUser.phoneNumber;

        final url = "${globals.urlStem}/addUser";
        final payload = jsonEncode({
          'uid': uid,
          'email': email,
          'phone': phone,
          'name': '',
          'notification': '1'
        });
        final response = await http
            .post(url,
                headers: {'Content-Type': 'application/json'}, body: payload)
            .catchError((error) {
          print("User exists. Logging in.");
        });

        final urlLogin = "${globals.urlStem}/login";
        final responseLogin = await http.get(urlLogin);

        print("is web ?................................ $kIsWeb");

        if (!kIsWeb) {
          FirebaseMessaging fbmInstance = FirebaseMessaging();
          fbmInstance.requestNotificationPermissions();
          fbmInstance.configure(onMessage: (msg) {
            return;
          }, onLaunch: (msg) {
            return;
          }, onResume: (msg) {
            return;
          });
          fbmInstance.subscribeToTopic("$uid");
        }

        Navigator.of(context).pushNamed(ClassesScreen.routeName);

        break;
      case AuthorizationStatus.error:
        showDialog(
          context: context,
          child: CupertinoAlertDialog(
            title: Text("Apple Sign In Failed"),
            content: Text(
              "Something went wrong. Please try again.",
            ),
            actions: [
              CupertinoDialogAction(
                child: Text("Ok"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future<void> _submitAuthForm(
    String email,
    String phone,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) async {
    setState(() {
      _isLoading = true;
    });
    //Check if there's a scaffold, then if there is...
    //Scaffold.of(context).removeCurrentSnackBar();
    if (isLogin) {
      _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        final url = "${globals.urlStem}/login";
        final response = await http.get(url);
        Navigator.of(context).pushNamed(ClassesScreen.routeName);
      }).catchError(
        (error) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Invalid credentials! Please try again!"),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          setState(
            () {
              _isLoading = false;
            },
          );
        },
      );
    } else {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        final uid = FirebaseAuth.instance.currentUser.uid;
        //print(uid);
        //const url = "https://cap1.herpin.net:5000/add";
        final url = "${globals.urlStem}/addUser";
        final payload = jsonEncode({
          'uid': uid,
          'email': email,
          'phone': phone,
          'name': '',
          'notification': '1'
        });
        final response = await http.post(url,
            headers: {'Content-Type': 'application/json'}, body: payload);

        if (!kIsWeb) {
          FirebaseMessaging fbmInstance = FirebaseMessaging();
          fbmInstance.requestNotificationPermissions();
          fbmInstance.configure(onMessage: (msg) {
            return;
          }, onLaunch: (msg) {
            return;
          }, onResume: (msg) {
            return;
          });
          fbmInstance.subscribeToTopic("$uid");
        }

        Navigator.of(context).pushNamed(ClassesScreen.routeName);
      }).catchError(
        (error) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Scaffold.of(ctx).showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          setState(
            () {
              _isLoading = false;
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
          _submitAuthForm, _signInWithGoogle, _signInWithApple, _isLoading),
    );
  }
}
