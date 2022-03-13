import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/constants.dart';

class ReusableTile extends StatelessWidget {
  Widget child;
  Color color;

  ReusableTile({required this.child, this.color = kBoxColorTop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
      width: double.infinity,
      child: Center(child: child),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: color,
      ),
    );
  }
}
