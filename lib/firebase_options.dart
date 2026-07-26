import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDK5j7JAXxxIdtsbzYbMZSPSjr6vUL48hs',
    appId: '1:538757616550:android:cb9c0c0928cc4b9baef567',
    messagingSenderId: '538757616550',
    projectId: 'hasan-abbas-portfolio',
    storageBucket: 'hasan-abbas-portfolio.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDK5j7JAXxxIdtsbzYbMZSPSjr6vUL48hs',
    appId: '1:538757616550:ios:2135afcf1157d335aef567',
    messagingSenderId: '538757616550',
    projectId: 'hasan-abbas-portfolio',
    storageBucket: 'hasan-abbas-portfolio.firebasestorage.app',
    iosBundleId: 'hasanabbas.dev.portfolio',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDK5j7JAXxxIdtsbzYbMZSPSjr6vUL48hs',
    appId: '1:538757616550:web:a3b0f65fadcb1f21aef567',
    messagingSenderId: '538757616550',
    projectId: 'hasan-abbas-portfolio',
    storageBucket: 'hasan-abbas-portfolio.firebasestorage.app',
    authDomain: 'hasan-abbas-portfolio.firebaseapp.com',
  );
}
