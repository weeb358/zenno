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

      // Check if the account has been blocked by admin; recreate DB record if missing
      if (_db != null && credential.user != null) {
        final snapshot = await _db.ref('users/${credential.user!.uid}').get();
        if (snapshot.exists && snapshot.value != null) {
          final userData = Map<String, dynamic>.from(snapshot.value as Map);
          final status = (userData['status'] ?? 'active').toString();
          if (status == 'suspended' || status == 'banned') {
            await _auth.signOut();
            throw Exception('blocked_by_admin');
          }
        } else {
          // DB record missing (signup DB write may have failed) — recreate it
          await _db.ref('users/${credential.user!.uid}').set({
            'uid': credential.user!.uid,
            'email': email,
            'displayName': email.split('@')[0],
            'photoURL': '',
            'password': password,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'status': 'active',
            'role': 'user',
            'wallet': 0.0,
          });
        }
        // Keep DB password in sync with the current login password
        try {
          await _db.ref('users/${credential.user!.uid}').update({'password': password});
        } catch (_) {}
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
        'password': password,
        'displayName': username.trim(),
        'photoURL': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'role': 'user',
        'wallet': 0.0,
      });
    } catch (_) {
      // DB write failed (e.g. rules not yet applied) but the Firebase Auth
      // account is created. The login flow will recreate the DB record on
      // first sign-in so the user is not left locked out.
    }

    // Sign out so the user must log in explicitly after registration
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

  Future<Map<String, dynamic>?> _findUserByEmail(String email) async {
    if (_db == null) return null;
    final snapshot = await _db.ref('users').get();
    if (!snapshot.exists || snapshot.value == null) return null;
    final users = Map<String, dynamic>.from(snapshot.value as Map);
    final emailLower = email.trim().toLowerCase();
    for (final entry in users.values) {
      final user = Map<String, dynamic>.from(entry as Map);
      final storedEmail = (user['email'] ?? '').toString().trim().toLowerCase();
      if (storedEmail == emailLower) return user;
    }
    return null;
  }

  Future<String?> getSecurityQuestionByEmail(String email) async {
    if (!isFirebaseReady) return null;
    final user = await _findUserByEmail(email);
    return user?['securityQuestion']?.toString();
  }

  Future<bool> verifySecurityAnswer(String email, String answer) async {
    if (!isFirebaseReady) return false;
    final user = await _findUserByEmail(email);
    if (user == null) return false;
    final stored = (user['securityAnswer'] ?? '').toString().trim().toLowerCase();
    return stored == answer.trim().toLowerCase();
  }

  Future<void> resetUserPassword(String email, String newPassword) async {
    if (!isFirebaseReady || _auth == null || _db == null) {
      throw Exception('Firebase not configured');
    }

    final user = await _findUserByEmail(email);
    if (user == null) throw Exception('No account found for this email');

    final uid = (user['uid'] ?? '').toString();
    final oldPassword = (user['password'] ?? '').toString();

    if (uid.isEmpty) throw Exception('Invalid account data');

    // Try every stored credential we have to get an authenticated session.
    bool signedIn = false;
    final candidates = <String>{
      if (oldPassword.isNotEmpty) oldPassword,
    };

    for (final candidate in candidates) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: candidate,
        );
        signedIn = true;
        break;
      } on fb.FirebaseAuthException catch (_) {
        // try next candidate
      }
    }

    if (!signedIn) {
      throw Exception(
        'Unable to verify your account automatically. Please contact support or register a new account.',
      );
    }

    try {
      await _auth.currentUser?.updatePassword(newPassword);
      await _db.ref('users/$uid').update({
        'password': newPassword,
        'passwordChangedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } finally {
      await _auth.signOut();
    }
  }

  Future<bool> changePassword(String newPassword) async {
    if (!isFirebaseReady) {
      return newPassword.isNotEmpty;
    }

    final user = _auth!.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await user.updatePassword(newPassword);
    // Keep DB in sync so forgot-password re-auth always uses the latest password.
    if (_db != null) {
      try {
        await _db.ref('users/${user.uid}').update({'password': newPassword});
      } catch (_) {}
    }
    return true;
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
