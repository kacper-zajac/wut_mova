import 'package:flutter/material.dart';
import 'package:mova/views/widgets/animated_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: AnimatedLogo(
          isFullLogo: false,
        ),
      ),
    );
  }
}
