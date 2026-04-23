import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

/// Wraps FirebaseAuth + Google Sign-In. Stateless; single instance.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirestoreService? firestoreService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestoreService ?? FirestoreService();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestore;

  /// Stream of Firebase auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase user (nullable).
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  /// Sign in with email and password.
  /// Throws [AuthException] with a human-readable message on failure.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    }
  }

  /// Create a new account with email, password, and display name.
  /// Also creates the Firestore user document.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Update Firebase profile display name
      await credential.user!.updateDisplayName(displayName.trim());

      // Create Firestore user document
      await _firestore.createUserDoc(UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      ));

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Sign in with Google. Creates a Firestore user doc on first sign-in.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create user doc if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.createUserDoc(UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? '',
          createdAt: DateTime.now(),
          photoUrl: userCredential.user!.photoURL,
        ));
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    } catch (e) {
      throw AuthException(message: 'Google sign-in failed. Please try again.');
    }
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

// ---------------------------------------------------------------------------
// AuthException
// ---------------------------------------------------------------------------

/// User-friendly auth error.
class AuthException implements Exception {
  const AuthException({required this.message});

  final String message;

  factory AuthException.fromFirebaseCode(String code) {
    return AuthException(message: _messageFor(code));
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email. Sign up first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() => 'AuthException: $message';
}
