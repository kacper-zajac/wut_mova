import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/provider/application_state.dart';
import 'package:mova/views/auth/authentication.dart';
import 'package:mova/views/widgets/animated_logo.dart';
import 'package:mova/views/widgets/sign_in_widget.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  static const id = 'welcomescreen';

  const WelcomeScreen({Key? key}) : super(key: key);

  // TODO add stuff to the welcome screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Hero(
              tag: 'logo',
              child: AnimatedLogo(isFullLogo: true),
            ),
          ),
          SignInWidget(),
        ],
      ),
    );
  }
}
