import 'package:flutter/material.dart';
import 'package:mova/views/menu/menu_screen.dart';
import 'package:mova/views/video/video_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: VideoScreen.id,
      routes: {
        VideoScreen.id : (context) => VideoScreen(),
        MenuScreen.id : (context) => MenuScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
    );
  }
}