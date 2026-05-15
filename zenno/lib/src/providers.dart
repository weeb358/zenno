import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

import 'services/auth_service.dart';
import 'services/admin_service.dart';
import 'services/game_service.dart';
import 'services/storage_service.dart';
import 'services/user_data_service.dart';
import '../firebase_options.dart';

/// ------------------------------
/// 🔥 Firebase State
/// ------------------------------
final firebaseReadyProvider = StateProvider<bool>((ref) => false);

class LocalAuthSession {
  final String username;
  final String email;
  final String role;

  const LocalAuthSession({
    required this.username,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}

final localAuthSessionProvider = StateProvider<LocalAuthSession?>((ref) => null);

final firebaseAuthProvider =
    Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);

final googleSignInProvider =
    Provider<GoogleSignIn>((ref) => GoogleSignIn());

final realtimeDatabaseProvider =
    Provider<FirebaseDatabase>((ref) => FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
        ));

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
  final userAsync = ref.watch(authStateChangesProvider);
  final user = userAsync.value;
  if (user == null) return const Stream.empty();

  final db = ref.read(realtimeDatabaseProvider);
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

final gameServiceProvider = Provider<GameService>((ref) {
  final db = ref.read(realtimeDatabaseProvider);
  return GameService(db);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final allUsersStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  try {
    final adminService = ref.read(adminServiceProvider);
    return adminService.getUsersStream().transform(
      StreamTransformer<List<Map<String, dynamic>>, List<Map<String, dynamic>>>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) => sink.add([]),
      ),
    );
  } catch (e) {
    return Stream.value([]);
  }
});

final userStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  try {
    return await adminService.getUserStatistics().timeout(
      const Duration(seconds: 5),
      onTimeout: () => {
        'totalUsers': 0,
        'activeUsers': 0,
        'suspendedUsers': 0,
        'bannedUsers': 0,
      },
    );
  } catch (e) {
    return {
      'totalUsers': 0,
      'activeUsers': 0,
      'suspendedUsers': 0,
      'bannedUsers': 0,
    };
  }
});

final gamesStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  final gameService = ref.read(gameServiceProvider);
  return gameService.getGamesStream();
});

final gamesByCategoryProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, category) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  final gameService = ref.read(gameServiceProvider);
  return gameService.getGamesStream(category: category);
});

final gameByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, gameId) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;
  final gameService = ref.read(gameServiceProvider);
  return gameService.getGameById(gameId);
});

/// ------------------------------
/// 👤 USER DATA (wishlist / cart / purchases)
/// ------------------------------
final userDataServiceProvider = Provider<UserDataService>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  final db = ref.read(realtimeDatabaseProvider);
  return UserDataService(auth, db);
});

final wishlistStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  final service = ref.read(userDataServiceProvider);
  return service.getWishlistStream();
});

final cartStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  final service = ref.read(userDataServiceProvider);
  return service.getCartStream();
});

final purchaseHistoryStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  final service = ref.read(userDataServiceProvider);
  return service.getPurchaseHistoryStream();
});