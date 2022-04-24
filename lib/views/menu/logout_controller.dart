import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/provider/application_state.dart';
import 'package:mova/views/auth/authentication.dart';
import 'package:mova/views/auth/welcome_screen.dart';
import 'package:provider/provider.dart';

class LogoutController extends StatelessWidget {
  const LogoutController({Key? key}) : super(key: key);

  void handleLogout(BuildContext context) {
    if (Provider.of<ApplicationState>(context, listen: false).loginState ==
        ApplicationLoginState.loggedIn) {
      Provider.of<ApplicationState>(context, listen: false).signOut();
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      WelcomeScreen.id,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => handleLogout(context),
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: kBoxColorTop,
      icon: const Icon(
        Icons.logout_rounded,
        color: Colors.white,
      ),
    );
  }
}
