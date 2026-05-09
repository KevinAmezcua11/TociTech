import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  static bool _initialized = false;
  static Object? _error;

  static bool get isInitialized => _initialized;
  static Object? get error => _error;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _initialized = true;
      _error = null;
    } catch (error) {
      _initialized = false;
      _error = error;
    }
  }
}
