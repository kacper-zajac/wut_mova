import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/provider/application_state.dart';
import 'package:mova/views/auth/authentication.dart';
import 'package:provider/provider.dart';

class SignInWidget extends StatefulWidget {
  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration(seconds: 1),
        () => {
              setState(() {
                _opacity = 1.0;
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(seconds: 1),
      child: Container(
        decoration: BoxDecoration(
          color: kBoxColorBottom.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(75.0),
            topLeft: Radius.circular(75.0),
          ),
          boxShadow: const [
            BoxShadow(
              color: kBoxColorTop,
              spreadRadius: 2,
              blurRadius: 50, // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
          child: Center(
            child: Consumer<ApplicationState>(
              builder: (context, appState, _) => Authentication(
                email: appState.email,
                loginState: appState.loginState,
                startLoginFlow: appState.startLoginFlow,
                verifyEmail: appState.verifyEmail,
                signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
                cancelRegistration: appState.cancelRegistration,
                registerAccount: appState.registerAccount,
                signOut: appState.signOut,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
