import 'package:firebase_core/firebase_core.dart';

class FirebaseHandler {
  static Future<void> initFirebase() async {
    await Firebase.initializeApp();
  }
}