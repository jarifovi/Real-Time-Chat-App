import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for project: real-time-chat-app-eae59
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
    apiKey: 'AIzaSyAEmKMDchdHzCUp3u7-fP0BQE-wp-opfak',
    appId: '1:64531853621:web:b1d830b5e56d782f0adfe8',
    messagingSenderId: '64531853621',
    projectId: 'real-time-chat-app-eae59',
    authDomain: 'real-time-chat-app-eae59.firebaseapp.com',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEmKMDchdHzCUp3u7-fP0BQE-wp-opfak',
    appId: '1:64531853621:android:b1d830b5e56d782f0adfe8',
    messagingSenderId: '64531853621',
    projectId: 'real-time-chat-app-eae59',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAEmKMDchdHzCUp3u7-fP0BQE-wp-opfak',
    appId: '1:64531853621:ios:b1d830b5e56d782f0adfe8',
    messagingSenderId: '64531853621',
    projectId: 'real-time-chat-app-eae59',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
    iosBundleId: 'com.example.realTimeChatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAEmKMDchdHzCUp3u7-fP0BQE-wp-opfak',
    appId: '1:64531853621:ios:b1d830b5e56d782f0adfe8',
    messagingSenderId: '64531853621',
    projectId: 'real-time-chat-app-eae59',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
    iosBundleId: 'com.example.realTimeChatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAEmKMDchdHzCUp3u7-fP0BQE-wp-opfak',
    appId: '1:64531853621:web:b1d830b5e56d782f0adfe8',
    messagingSenderId: '64531853621',
    projectId: 'real-time-chat-app-eae59',
    authDomain: 'real-time-chat-app-eae59.firebaseapp.com',
    storageBucket: 'real-time-chat-app-eae59.firebasestorage.app',
  );
}
