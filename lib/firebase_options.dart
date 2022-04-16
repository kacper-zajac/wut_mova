// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDR3PyXAEwvWTk2A0bAn8JPgnVKh_YfcoE',
    appId: '1:572074800008:android:3ef1a46b78ede8f324003d',
    messagingSenderId: '572074800008',
    projectId: 'wut-mova-344119',
    storageBucket: 'wut-mova-344119.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZqL0pJFxe9_VoJq1M_hEEa0-JwK-YLpw',
    appId: '1:572074800008:ios:d891074fa5469d7c24003d',
    messagingSenderId: '572074800008',
    projectId: 'wut-mova-344119',
    storageBucket: 'wut-mova-344119.appspot.com',
    iosClientId: '572074800008-kpl0kc44u7vqb7o8iq5rqvs98vgjugrc.apps.googleusercontent.com',
    iosBundleId: 'pl.kacperzajac.mova',
  );
}
