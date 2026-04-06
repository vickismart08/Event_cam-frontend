// Generated-style config for project eventcam-76ee3 (web values from Firebase console).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBsNlP84dMSMv03bBl_3cuvwM59VMWHJY',
    appId: '1:915573286177:web:3eb4d391780cdeaa924a60',
    messagingSenderId: '915573286177',
    projectId: 'eventcam-76ee3',
    authDomain: 'eventcam-76ee3.firebaseapp.com',
    storageBucket: 'eventcam-76ee3.firebasestorage.app',
    measurementId: 'G-G5NS3N200S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBsNlP84dMSMv03bBl_3cuvwM59VMWHJY',
    appId: '1:915573286177:android:placeholder',
    messagingSenderId: '915573286177',
    projectId: 'eventcam-76ee3',
    storageBucket: 'eventcam-76ee3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBsNlP84dMSMv03bBl_3cuvwM59VMWHJY',
    appId: '1:915573286177:ios:placeholder',
    messagingSenderId: '915573286177',
    projectId: 'eventcam-76ee3',
    storageBucket: 'eventcam-76ee3.firebasestorage.app',
    iosBundleId: 'com.example.eventCamshot',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = web;
}
