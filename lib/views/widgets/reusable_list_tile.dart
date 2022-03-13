import 'package:flutter/material.dart';
import 'package:mova/views/widgets/reusable_tile.dart';

import '../../constants.dart';

ReusableTile ReusableListTile(
    {required String text, required String date, required IconData icon}) {
  return ReusableTile(
    child: ListTile(
      leading: Icon(icon, color: Colors.white,),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: kBoxBottomTextStyle,
          ),
          Text(
            date,
            style: kBoxBottomTextStyle,
          ),
        ],
      ),
    ),
  );
}
