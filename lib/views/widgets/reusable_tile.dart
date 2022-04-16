import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/constants.dart';

class ReusableTile extends StatelessWidget {
  final Widget child;
  final Color color;
  final Function()? onPress;

  ReusableTile({required this.child, this.color = kBoxColorTop, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
      width: double.infinity,
      child: Center(
        child: TextButton(onPressed: onPress, child: child),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: color,
      ),
    );
  }
}
