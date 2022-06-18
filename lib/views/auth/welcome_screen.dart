import 'package:flutter/material.dart';
import 'package:mova/views/widgets/animated_logo.dart';
import 'package:mova/views/widgets/sign_in_widget.dart';

class WelcomeScreen extends StatelessWidget {
  static const id = 'welcomescreen';

  const WelcomeScreen({Key? key}) : super(key: key);

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
