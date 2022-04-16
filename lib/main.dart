import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/views/menu/menu_screen.dart';
import 'package:mova/views/menu/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      initialRoute: MenuScreen.id,
      routes: {
        MainScreen.id: (context) => MainScreen(),
        MenuScreen.id: (context) => MenuScreen(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}
