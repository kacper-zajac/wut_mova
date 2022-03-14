import 'package:flutter/material.dart';
import 'package:mova/views/widgets/reusable_tile.dart';

class MenuScreen extends StatelessWidget {

  static const id = 'menuscreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReusableTile(child: Text('hello'),),
    );
  }
}
