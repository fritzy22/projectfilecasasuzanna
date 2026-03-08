import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDYlFa7IUsxAperMhQ2KEJ6pGMcE4-7TYk',
    appId: '1:447833641879:web:0239e18b4c8f10a23dead2',
    messagingSenderId: '447833641879',
    projectId: 'projectfilecasasuzanna',
    authDomain: 'projectfilecasasuzanna.firebaseapp.com',
    storageBucket: 'projectfilecasasuzanna.firebasestorage.app',
    measurementId: 'G-EG8G3CFSV4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBT9rWyM6OiF__JZKVjWqUjVecW_4RVUg',
    appId: '1:447833641879:android:3b9b1f24928d1b403dead2',
    messagingSenderId: '447833641879',
    projectId: 'projectfilecasasuzanna',
    storageBucket: 'projectfilecasasuzanna.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXHd7rm29B2AB8EJsVPKncPJooC_qTWmM',
    appId: '1:447833641879:ios:796e7b9dd91e7bf03dead2',
    messagingSenderId: '447833641879',
    projectId: 'projectfilecasasuzanna',
    storageBucket: 'projectfilecasasuzanna.firebasestorage.app',
    iosBundleId: 'com.example.projectfilecasasuzanna',
  );
}
