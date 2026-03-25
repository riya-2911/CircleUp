import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String _webGoogleClientId =
      '191633865917-sesgn2015a87skvkjugsdh9vr93l69r8.apps.googleusercontent.com';

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign-In
  static Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      // Preferred web flow when Firebase is initialized correctly.
      if (_isFirebaseReady) {
        await _auth.signInWithPopup(GoogleAuthProvider());
        return true;
      }

      // Fallback for dev phase: sign in via Google only so app flow can continue.
      final GoogleSignIn webGoogleSignIn = GoogleSignIn(clientId: _webGoogleClientId);
      final GoogleSignInAccount? googleUser = await webGoogleSignIn.signIn();
      return googleUser != null;
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;

    // If Firebase isn't ready yet, still allow login flow in prototype mode.
    if (!_isFirebaseReady) return true;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    return true;
  }

  // Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    if (_isFirebaseReady) {
      await _auth.signOut();
    }
  }

  // Get display name
  static String get displayName => currentUser?.displayName ?? 'User';
  static String get email => currentUser?.email ?? '';
  static String? get photoUrl => currentUser?.photoURL;
}
