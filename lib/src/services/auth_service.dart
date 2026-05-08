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

  Future<bool> signInWithEmail(String email, String password) async {
    if (!isFirebaseReady) {
      return email.isNotEmpty && password.isNotEmpty;
    }

    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      // If admin account doesn't exist, create it automatically for development convenience
      if (e.code == 'user-not-found' && ( email == 'admin')) {
        final created = await _auth!.createUserWithEmailAndPassword(email: 'admin', password: 'admin@123');
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
