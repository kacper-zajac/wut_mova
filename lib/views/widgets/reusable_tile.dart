import 'package:flutter/material.dart';

class ReusableTile extends StatelessWidget {

  Widget child;

  ReusableTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: child,
      decoration: const BoxDecoration(
        gradient: SweepGradient(
          colors: [
            Colors.red,
            Colors.blue
          ]
        )
      ),
    );
  }
}
