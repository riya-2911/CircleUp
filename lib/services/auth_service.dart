import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static const String _webGoogleClientId =
      '191633865917-sesgn2015a87skvkjugsdh9vr93l69r8.apps.googleusercontent.com';

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const <String>['email', 'profile'],
    serverClientId: _webGoogleClientId,
  );

  static bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign-In
  static Future<bool> signInWithGoogle() async {
    try {
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
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapFirebaseAuthError(e));
    } catch (e) {
      final mapped = _mapGoogleSignInError(e);

      // Dev-safe fallback: if Google services are unavailable but Firebase works,
      // continue app access using anonymous Firebase auth.
      final canFallbackToAnonymous = _isFirebaseReady &&
          (mapped.contains('Google Play Services') || mapped.contains('network'));

      if (canFallbackToAnonymous) {
        try {
          await _auth.signInAnonymously();
          return true;
        } catch (_) {
          // Fall through to user-facing mapped error.
        }
      }

      throw AuthServiceException(_mapGoogleSignInError(e));
    }
  }

  static String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Network issue while signing in. Check your internet and try again.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked with another sign-in method.';
      case 'invalid-credential':
        return 'Google credential is invalid. Please try again.';
      default:
        return 'Google sign-in failed. Please try again.';
    }
  }

  static String _mapGoogleSignInError(Object e) {
    final message = e.toString().toLowerCase();

    if (message.contains('sign_in_canceled') || message.contains('cancel')) {
      return 'Google sign-in was cancelled.';
    }

    if (message.contains('apiexception: 7') || message.contains('network_error')) {
      return 'Google Play Services or network is unavailable on this device. Try again or use phone/college login.';
    }

    if (message.contains('apiexception: 10') || message.contains('developer_error')) {
      return 'Google sign-in configuration issue detected. Please verify SHA and Firebase setup.';
    }

    return 'Unable to sign in with Google right now. Please try again.';
  }

  // Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    if (_isFirebaseReady) {
      await _auth.signOut();
    }
  }

  // Get display name
  // Sign in anonymously (for local users to access Firestore)
  static Future<bool> signInAnonymously() async {
    try {
      if (!_isFirebaseReady) {
        return false;
      }
      
      // Only sign in if not already authenticated
      if (_auth.currentUser != null) {
        return true;
      }
      
      await _auth.signInAnonymously();
      debugPrint('Signed in anonymously for Firestore access');
      return true;
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
      return false;
    }
  }

  // Get display name
  static String get displayName => currentUser?.displayName ?? 'User';
  static String get email => currentUser?.email ?? '';
  static String? get photoUrl => currentUser?.photoURL;
}
