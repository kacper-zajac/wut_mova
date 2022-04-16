import 'package:flutter/material.dart';
import 'package:mova/provider/application_state.dart';
import 'package:mova/views/auth/authentication.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  static const id = 'welcomescreen';

  const WelcomeScreen({Key? key}) : super(key: key);


  // TODO add stuff to the welcome screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
    );
  }
}
