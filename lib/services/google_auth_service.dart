

import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await _googleSignIn.initialize(
           serverClientId: '772272943490-vs9s6tfh0kit7uf84gsq03u9o2bmqpdq.apps.googleusercontent.com',

    );

    _initialized = true;
  }

  static Future<GoogleSignInAccount?> signIn() async {
    if (!_initialized) {
      await initialize();
    }

    return await _googleSignIn.authenticate();
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}