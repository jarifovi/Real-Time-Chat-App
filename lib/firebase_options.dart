import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for project: real-time-chat-app-eae59
///
/// If using Web, Android, or iOS apps, paste your web API key and App ID
/// from your Firebase Console (Project Settings > General).
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
    apiKey: 'AIzaSyDemoPlaceholderKeyForRealTimeChatApp',
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'real-time-chat-app-eae59',
    authDomain: 'real-time-chat-app-eae59.firebaseapp.com',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderKeyForRealTimeChatApp',
    appId: '1:1234567890:android:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'real-time-chat-app-eae59',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderKeyForRealTimeChatApp',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'real-time-chat-app-eae59',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
    iosBundleId: 'com.example.realTimeChatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderKeyForRealTimeChatApp',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'real-time-chat-app-eae59',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
    iosBundleId: 'com.example.realTimeChatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderKeyForRealTimeChatApp',
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'real-time-chat-app-eae59',
    authDomain: 'real-time-chat-app-eae59.firebaseapp.com',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
  );
}
