// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCy8rOWJFhdngpjfIvQ-nE4MPYrJ-VQ5Uw',
    appId: '1:130363947190:web:5aaed0a4d9548c944d4e17',
    messagingSenderId: '130363947190',
    projectId: 'hooh-flutter',
    authDomain: 'hooh-flutter.firebaseapp.com',
    storageBucket: 'hooh-flutter.appspot.com',
    measurementId: 'G-WMEKWX0LKR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCl2xkItf5jB-_nEQzaFYfl8T_iqz6zDc',
    appId: '1:130363947190:android:ba6db941458ae6fe4d4e17',
    messagingSenderId: '130363947190',
    projectId: 'hooh-flutter',
    storageBucket: 'hooh-flutter.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcodNJvmGApLEY0-vlH73Fgc3adk9pa4k',
    appId: '1:130363947190:ios:d2defac046a877ab4d4e17',
    messagingSenderId: '130363947190',
    projectId: 'hooh-flutter',
    storageBucket: 'hooh-flutter.appspot.com',
    iosClientId: '130363947190-k40hvk0k352flcd6ijdgt7k9vlld3res.apps.googleusercontent.com',
    iosBundleId: 'cn.logicdesign.test',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDcodNJvmGApLEY0-vlH73Fgc3adk9pa4k',
    appId: '1:130363947190:ios:7e529434aa8c34354d4e17',
    messagingSenderId: '130363947190',
    projectId: 'hooh-flutter',
    storageBucket: 'hooh-flutter.appspot.com',
    iosClientId: '130363947190-c795gqmgv7cqkf3frhned255g1d76hof.apps.googleusercontent.com',
    iosBundleId: 'xyz.hooh.app',
  );
}
