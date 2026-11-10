import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for Revida.
///
/// Android only. Values match `android/app/google-services.json` for
/// Firebase project `revida-bbadb` (project number 380496289978,
/// app id `1:380496289978:android:ff184e5034267b92ada283`,
/// package `app.marcomendez.revida`).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Revida only supports Android and is configured for Firebase '
        'project revida-bbadb.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Revida only supports Android (Firebase project revida-bbadb). '
          '${defaultTargetPlatform.name} is not configured.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQyWT-aOUeqVtyGkqSBFA-skcOf_x0clU',
    appId: '1:380496289978:android:ff184e5034267b92ada283',
    messagingSenderId: '380496289978',
    projectId: 'revida-bbadb',
    storageBucket: 'revida-bbadb.firebasestorage.app',
  );
}
