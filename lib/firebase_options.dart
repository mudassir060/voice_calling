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
    apiKey: 'AIzaSyAu2Aesa_tSzyKtWMC45AUa8jkyJRs12-8',
    appId: '1:140864617705:web:b70e75005e3bb752dd8478',
    messagingSenderId: '140864617705',
    projectId: 'test-a70',
    authDomain: 'test-a70.firebaseapp.com',
    storageBucket: 'test-a70.appspot.com',
    measurementId: 'G-D7B13ZRRZ9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQQQSVgF8uGuMZ1_76poo_OJyVyuMMJlw',
    appId: '1:140864617705:android:ecd931a9366e8b1edd8478',
    messagingSenderId: '140864617705',
    projectId: 'test-a70',
    storageBucket: 'test-a70.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDtTZrFunjPkPOe4Kw8asa8XHhRcW-o-AI',
    appId: '1:140864617705:ios:a4e3d898ebc960cbdd8478',
    messagingSenderId: '140864617705',
    projectId: 'test-a70',
    storageBucket: 'test-a70.appspot.com',
    iosClientId: '140864617705-pod9dkd2pc9sc6ns8diol6aoncua0aq8.apps.googleusercontent.com',
    iosBundleId: 'com.example.voiceCalling',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDtTZrFunjPkPOe4Kw8asa8XHhRcW-o-AI',
    appId: '1:140864617705:ios:92787692ac925165dd8478',
    messagingSenderId: '140864617705',
    projectId: 'test-a70',
    storageBucket: 'test-a70.appspot.com',
    iosClientId: '140864617705-dc75llm8nvomikqr9301uf9upbmian43.apps.googleusercontent.com',
    iosBundleId: 'com.example.voiceCalling.RunnerTests',
  );
}
