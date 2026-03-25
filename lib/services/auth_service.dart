import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '191633865917-sesgn2015a87skvkjugsdh9vr93l69r8.apps.googleusercontent.com',
  );

  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign-In
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get display name
  static String get displayName => currentUser?.displayName ?? 'User';
  static String get email => currentUser?.email ?? '';
  static String? get photoUrl => currentUser?.photoURL;
}
