import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

//TODO wiecej tego i używać tego
class Header extends StatelessWidget {
  const Header(this.heading);

  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: kLoginFormLabelText,
        ),
      );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content);

  final String content;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          content,
          style: const TextStyle(fontSize: 18),
        ),
      );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail);

  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              detail,
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
      );
}

class StyledButton extends StatelessWidget {
  StyledButton({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.controller,
    this.width = 150.0,
    this.durationInSeconds = 5,
    this.resetAfterDuration = true,
  }) : super(key: key);

  final Widget child;
  final void Function() onPressed;
  final RoundedLoadingButtonController controller;
  final double width;
  final int durationInSeconds;
  final bool resetAfterDuration;

  @override
  Widget build(BuildContext context) => RoundedLoadingButton(
        color: kBoxColorTop,
        successColor: Colors.lightBlueAccent,
        disabledColor: Colors.white,
        height: 40.0,
        elevation: 3.0,
        width: width,
        borderRadius: 10.0,
        resetAfterDuration: resetAfterDuration,
        resetDuration: Duration(seconds: durationInSeconds),
        controller: controller,
        onPressed: onPressed,
        child: child,
      );
}
