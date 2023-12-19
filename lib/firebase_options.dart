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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_NdWgaLjZMxDnyOlI-FN99bw_dQWqNgs',
    appId: '1:255799660604:web:4e5fcaabd3a970092f3339',
    messagingSenderId: '255799660604',
    projectId: 'azan-eoip',
    authDomain: 'azan-eoip.firebaseapp.com',
    storageBucket: 'azan-eoip.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrld4b59Wu-X3Z_Tu26nQJDuDRqIVios0',
    appId: '1:255799660604:android:fc0da8186f3dc5b72f3339',
    messagingSenderId: '255799660604',
    projectId: 'azan-eoip',
    storageBucket: 'azan-eoip.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBBhLBkyU0Z143M_5ziTypgneKlWd0zLI',
    appId: '1:255799660604:ios:5eb0f6a3f26695c92f3339',
    messagingSenderId: '255799660604',
    projectId: 'azan-eoip',
    storageBucket: 'azan-eoip.appspot.com',
    iosBundleId: 'com.example.azan',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBBhLBkyU0Z143M_5ziTypgneKlWd0zLI',
    appId: '1:255799660604:ios:78df3af419bfef6b2f3339',
    messagingSenderId: '255799660604',
    projectId: 'azan-eoip',
    storageBucket: 'azan-eoip.appspot.com',
    iosBundleId: 'com.example.azan.RunnerTests',
  );
}