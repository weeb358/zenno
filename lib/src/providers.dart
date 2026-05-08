import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

import 'services/auth_service.dart';
import 'services/admin_service.dart';

/// ------------------------------
/// 🔥 Firebase State
/// ------------------------------
final firebaseReadyProvider = StateProvider<bool>((ref) => false);

final firebaseAuthProvider =
    Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);

final googleSignInProvider =
    Provider<GoogleSignIn>((ref) => GoogleSignIn());

final realtimeDatabaseProvider =
    Provider<FirebaseDatabase>((ref) => FirebaseDatabase.instance);

/// ------------------------------
/// 🔐 Auth Service
/// ------------------------------
final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);

  if (!firebaseReady) {
    throw Exception("Firebase not ready");
  }

  final auth = ref.read(firebaseAuthProvider);
  final google = ref.read(googleSignInProvider);
  final db = ref.read(realtimeDatabaseProvider);

  return AuthService(auth, google, db: db);
});

final authStateChangesProvider = StreamProvider<fb.User?>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);

  if (!firebaseReady) {
    return const Stream.empty();
  }

  final auth = ref.read(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// ------------------------------
/// 🛒 Simple Cart
/// ------------------------------
final cartProvider = StateProvider<double>((ref) => 0.0);

/// ------------------------------
/// 👑 ADMIN CONFIG
/// ------------------------------
const String adminEmail = 'admin@zenno.com';

final isUserAdminProvider = FutureProvider<bool>((ref) async {
  final userAsync = ref.watch(authStateChangesProvider);

  final user = userAsync.value;
  if (user == null) return false;

  return user.email == adminEmail;
});

/// ------------------------------
/// 👤 USER PROFILE (Realtime DB)
/// ------------------------------
final userProfileProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final userAsync = ref.watch(authStateChangesProvider);
  final user = userAsync.value;

  if (user == null) return null;

  final db = ref.read(realtimeDatabaseProvider);

  final snapshot = await db.ref('users/${user.uid}').get();

  if (!snapshot.exists || snapshot.value == null) return null;

  return Map<String, dynamic>.from(snapshot.value as Map);
});

final userProfileStreamProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  final db = ref.read(realtimeDatabaseProvider);

  final user = auth.currentUser;
  if (user == null) return const Stream.empty();

  return db.ref('users/${user.uid}').onValue.map((event) {
    if (event.snapshot.value == null) return null;
    return Map<String, dynamic>.from(event.snapshot.value as Map);
  });
});

/// ------------------------------
/// 👑 ADMIN SERVICE
/// ------------------------------
final adminServiceProvider = Provider<AdminService>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  final db = ref.read(realtimeDatabaseProvider);

  return AdminService(auth, db, adminEmail: adminEmail);
});

final allUsersStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getUsersStream();
});

final userStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getUserStatistics();
});