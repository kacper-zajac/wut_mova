import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mova/firebase_options.dart';
import 'package:mova/views/auth/authentication.dart';
import 'package:mova/views/menu/menu_screen.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
      }
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;


  String? _email;

  String? get email => _email;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<String> verifyEmail(String email) async {
    try {
      var methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
      return 'SUCCESS';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Unidentified error. Please try again!';
    }
  }

  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Future.delayed(Duration(seconds: 1), () {
        log(context.toString());
        log(MenuScreen.id);
        print(context);
        Navigator.pushNamed(context, MenuScreen.id);
      });
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
      return false;
    }
    return true;
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<bool> registerAccount(String email, String displayName, String password,
      BuildContext context, void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
      Future.delayed(
        Duration(seconds: 1),
        () => Navigator.pushReplacementNamed(context, MenuScreen.id),
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
      return false;
    }
    return true;
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
