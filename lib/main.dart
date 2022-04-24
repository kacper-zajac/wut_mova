import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mova/constants.dart';
import 'package:mova/provider/application_state.dart';
import 'package:mova/views/auth/welcome_screen.dart';
import 'package:mova/views/menu/work_screen.dart';
import 'package:mova/views/menu/menu_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        WorkScreen.id: (context) => WorkScreen(),
        MenuScreen.id: (context) => MenuScreen(),
      },
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme
        ),
        scaffoldBackgroundColor: kBackgroundColor,
        primarySwatch: Colors.grey,
      ),
    );
  }
}
