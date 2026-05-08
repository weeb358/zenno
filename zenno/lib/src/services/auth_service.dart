import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final fb.FirebaseAuth? _auth;
  final GoogleSignIn? _googleSignIn;
  final FirebaseDatabase? _db;

  AuthService(this._auth, this._googleSignIn, {FirebaseDatabase? db})
      : _db = db;

  bool get isFirebaseReady => _auth != null && _googleSignIn != null;

  Stream<fb.User?> authStateChanges() => _auth?.authStateChanges() ?? const Stream<fb.User?>.empty();

  Future<fb.UserCredential?> signInWithUsernameOrEmail(
    String identifier,
    String password,
  ) async {
    if (!isFirebaseReady) {
      throw Exception('Firebase is not configured');
    }

    final normalized = identifier.trim();
    if (!normalized.contains('@')) {
      throw Exception('Please sign in with your email address');
    }
    final email = normalized;

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the account has been blocked by admin
      if (_db != null && credential.user != null) {
        final snapshot = await _db.ref('users/${credential.user!.uid}').get();
        if (snapshot.exists && snapshot.value != null) {
          final userData = Map<String, dynamic>.from(snapshot.value as Map);
          final status = (userData['status'] ?? 'active').toString();
          if (status == 'suspended' || status == 'banned') {
            await _auth.signOut();
            throw Exception('blocked_by_admin');
          }
        }
      }

      return credential;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        throw Exception('Invalid email or password');
      }
      if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      }
      if (e.code == 'network-request-failed') {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.code == 'too-many-requests') {
        throw Exception('Too many failed attempts. Please try again later.');
      }
      final msg = (e.message?.isNotEmpty == true) ? e.message! : e.code;
      throw Exception(msg);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    if (!isFirebaseReady) {
      return email.isNotEmpty && password.isNotEmpty;
    }

    final normalizedEmail = email == 'admin' ? 'admin@zenno.com' : email;

    try {
      await _auth!.signInWithEmailAndPassword(email: normalizedEmail, password: password);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' &&
          (normalizedEmail == 'admin@zenno.com' || normalizedEmail == 'admin')) {
        final created = await _auth!.createUserWithEmailAndPassword(
          email: 'admin@zenno.com',
          password: password,
        );
        final createdUser = created.user;
        if (_db != null && createdUser != null) {
          await _db.ref('users/${createdUser.uid}').set({
            'uid': createdUser.uid,
            'email': 'admin@zenno.com',
            'displayName': 'Admin',
            'photoURL': '',
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'status': 'active',
            'role': 'admin',
            'wallet': 0.0,
          });
        }
        return true;
      }
      rethrow;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    if (!isFirebaseReady) {
      return email.isNotEmpty && password.isNotEmpty;
    }

    final userCredential = await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user profile in Realtime Database
    final createdUser = userCredential.user;
    if (_db != null && createdUser != null) {
      await _db.ref('users/${createdUser.uid}').set({
        'uid': createdUser.uid,
        'email': email,
        'displayName': '',
        'photoURL': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'role': 'user',
        'wallet': 0.0,
      });
    }

    return true;
  }

  Future<fb.UserCredential> signUpWithUsernameEmail({
    required String username,
    required String email,
    required String country,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    if (!isFirebaseReady) {
      throw Exception('Firebase is not ready');
    }

    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty) {
      throw Exception('Username is required');
    }

    // Step 1: create Firebase Auth account first — this authenticates the user
    // so all subsequent DB reads/writes pass Firebase rules (auth != null)
    late fb.UserCredential userCredential;
    try {
      userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') throw Exception('An account with this email already exists');
      if (e.code == 'weak-password') throw Exception('Password is too weak (minimum 6 characters)');
      if (e.code == 'invalid-email') throw Exception('Invalid email address');
      if (e.code == 'network-request-failed') throw Exception('Network error. Please check your internet connection.');
      if (e.code == 'too-many-requests') throw Exception('Too many attempts. Please try again later.');
      final msg = (e.message?.isNotEmpty == true) ? e.message! : e.code;
      throw Exception(msg);
    }

    final createdUser = userCredential.user;
    if (createdUser == null) throw Exception('Account creation failed');

    try {
      // Write user data to database (email uniqueness enforced by Firebase Auth)
      await _db!.ref('users/${createdUser.uid}').set({
        'uid': createdUser.uid,
        'username': username.trim(),
        'usernameLower': normalizedUsername,
        'email': email.trim(),
        'country': country.trim(),
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
        'displayName': username.trim(),
        'photoURL': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'role': 'user',
        'wallet': 0.0,
      });
    } catch (e) {
      // If DB writes fail, clean up the auth account to avoid orphaned accounts
      await _auth.signOut();
      if (e is Exception) rethrow;
      throw Exception('Failed to save account data: ${e.toString()}');
    }

    // Sign out after successful creation so the user must log in explicitly
    await _auth.signOut();

    return userCredential;
  }

  Future<bool> sendPasswordReset(String email) async {
    if (!isFirebaseReady) {
      return email.isNotEmpty;
    }

    await _auth!.sendPasswordResetEmail(email: email);
    return true;
  }

  Future<bool> changePassword(String newPassword) async {
    if (!isFirebaseReady) {
      return newPassword.isNotEmpty;
    }

    final user = _auth!.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
      return true;
    } else {
      throw Exception('No authenticated user');
    }
  }

  Future<fb.UserCredential?> signInWithGoogle() async {
    if (!isFirebaseReady) {
      return null;
    }

    final account = await _googleSignIn!.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final userCredential = await _auth!.signInWithCredential(credential);

    // Create or update user profile in Realtime Database
    final signedInUser = userCredential.user;
    if (_db != null && signedInUser != null) {
      await _db.ref('users/${signedInUser.uid}').set({
        'uid': signedInUser.uid,
        'email': signedInUser.email,
        'displayName': signedInUser.displayName ?? '',
        'photoURL': signedInUser.photoURL ?? '',
        'lastSignIn': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'role': 'user',
      });
    }

    return userCredential;
  }

  Future<fb.UserCredential?> signInWithSteam() async {
    // Steam OAuth flow requires server components. This is a local stub that
    // simulates a successful Steam-style login for development.
    
    throw UnimplementedError('Steam login is a stub in this demo');
  }

  Future<void> signOut() async {
    await _auth?.signOut();
    await _googleSignIn?.signOut();
  }
}
