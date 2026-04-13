// Configuración Firebase — proyecto: vibeshopping-4ffae
// Tras `flutterfire configure --project=vibeshopping-4ffae`, reemplaza valores con los de la consola.
// Los appId deben coincidir con el registro de cada app en ese proyecto.

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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions no están definidas para Linux — '
          'añade entradas o usa flutterfire configure.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no están definidas para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQ3OqK2GV6RrkXLaERLu-W3b9BR1JxeqY',
    appId: '1:932609847857:android:2dfc68dae15c0b2476db10',
    messagingSenderId: '932609847857',
    projectId: 'vibeshopping-4ffae',
    storageBucket: 'vibeshopping-4ffae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBocg1e_x7dXqcom6WU36aG9b-rh2BVOy0',
    appId: '1:654012492785:ios:780031b888a3a03055b250',
    messagingSenderId: '654012492785',
    projectId: 'vibeshopping-4ffae',
    storageBucket: 'vibeshopping-4ffae.firebasestorage.app',
    iosBundleId: 'com.vibeshipping.vibeshipping',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBocg1e_x7dXqcom6WU36aG9b-rh2BVOy0',
    appId: '1:654012492785:ios:780031b888a3a03055b250',
    messagingSenderId: '654012492785',
    projectId: 'vibeshopping-4ffae',
    storageBucket: 'vibeshopping-4ffae.firebasestorage.app',
    iosBundleId: 'com.vibeshipping.vibeshipping',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBocg1e_x7dXqcom6WU36aG9b-rh2BVOy0',
    appId: '1:654012492785:web:c58a16ea310505ea55b250',
    messagingSenderId: '654012492785',
    projectId: 'vibeshopping-4ffae',
    storageBucket: 'vibeshopping-4ffae.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBocg1e_x7dXqcom6WU36aG9b-rh2BVOy0',
    appId: '1:654012492785:web:362cfb88384e0fff55b250',
    messagingSenderId: '654012492785',
    projectId: 'vibeshopping-4ffae',
    storageBucket: 'vibeshopping-4ffae.firebasestorage.app',
  );
}
