import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Authentication with a clean interface for ApnaSolar.
///
/// Supports:
/// - Email/password registration and login
/// - Session persistence (Firebase handles this automatically)
/// - Authenticated profile resolution & sign out
///
/// All methods are no-ops when Firebase is not initialized (e.g., in tests
/// that don't bootstrap Firebase), preventing crashes.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Lazy getter — avoids crashing when Firebase is not initialized.
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  // ─── Streams ──────────────────────────────────────────────────────────────

  /// Emits the current [User] whenever auth state changes.
  /// Returns an empty stream when Firebase is not initialized.
  Stream<User?> get authStateChanges {
    final auth = _auth;
    if (auth == null) return const Stream.empty();
    return auth.authStateChanges();
  }

  // ─── State ────────────────────────────────────────────────────────────────

  /// Returns the currently signed-in [User], or null if not authenticated.
  User? get currentUser => _auth?.currentUser;

  /// True if a user is signed in (including anonymous).
  bool get isSignedIn => _auth?.currentUser != null;

  /// True if the current user is anonymous.
  bool get isAnonymous => _auth?.currentUser?.isAnonymous ?? false;

  /// Returns the uid of the current user, or null.
  String? get uid => _auth?.currentUser?.uid;

  // ─── Registration ─────────────────────────────────────────────────────────

  /// Creates a new account with [email] and [password].
  ///
  /// Throws [AuthException] on failure.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final auth = _auth;
    if (auth == null) throw Exception('Firebase is not initialized.');
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
    }
    return credential;
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Signs in with [email] and [password].
  ///
  /// Throws [AuthException] on failure.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) throw Exception('Firebase is not initialized.');
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Resolves the user's display name adhering strictly to the priority order:
  /// 1. Firebase Auth [displayName] (e.g. Google account display name or registered name)
  /// 2. User profile document's saved [name], [fullName], or [displayName]
  /// 3. Email username (characters before '@') only as a last fallback.
  static String resolveUserName({
    User? authUser,
    Map<String, dynamic>? profileDoc,
    String fallback = '',
  }) {
    // Priority 1: Firebase Auth displayName
    final authName = authUser?.displayName?.trim();
    if (authName != null && authName.isNotEmpty) {
      return authName;
    }

    // Priority 2: User profile document's saved name/fullName/displayName
    if (profileDoc != null) {
      final docName = profileDoc['name'];
      if (docName is String && docName.trim().isNotEmpty) {
        return docName.trim();
      }
      final docFullName = profileDoc['fullName'];
      if (docFullName is String && docFullName.trim().isNotEmpty) {
        return docFullName.trim();
      }
      final docDisplayName = profileDoc['displayName'];
      if (docDisplayName is String && docDisplayName.trim().isNotEmpty) {
        return docDisplayName.trim();
      }
    }

    // Priority 3: Email username only as last fallback
    final email = authUser?.email?.trim();
    if (email != null && email.contains('@')) {
      final emailPrefix = email.split('@').first.trim();
      if (emailPrefix.isNotEmpty) {
        return emailPrefix;
      }
    }

    return fallback;
  }

  /// Guest authentication is permanently removed.
  /// Throws [UnsupportedError] to prevent anonymous sign in.
  Future<UserCredential> signInAnonymously() async {
    throw UnsupportedError(
      'Guest access has been removed from ApnaSolar. Please sign in or create an account.',
    );
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth?.signOut();
  }

  /// Sends a password-reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) throw Exception('Firebase is not initialized.');
    await auth.sendPasswordResetEmail(email: email);
  }

  // ─── Error helpers ────────────────────────────────────────────────────────

  /// Returns a human-readable message for a [FirebaseAuthException].
  static String friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect email or password, or account does not exist. Please check or register.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please choose a stronger password (min. 6 characters).';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        debugPrint('FirebaseAuthException [${e.code}]: ${e.message}');
        return 'Something went wrong. Please try again.';
    }
  }

  /// True if Firebase has been initialized (i.e., Firebase.initializeApp has been called).
  static bool get isFirebaseInitialized {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }
}
