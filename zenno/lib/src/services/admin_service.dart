import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  final FirebaseAuth _auth;
  final FirebaseDatabase _db;
  final String adminEmail;

  AdminService(
    this._auth,
    this._db, {
    this.adminEmail = 'admin',
  });

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      return user.email == adminEmail ||
          user.email == '$adminEmail@zenno.com';
    } catch (_) {
      return false;
    }
  }

  // Get all users from database
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      late DataSnapshot snapshot;
      try {
        snapshot = await _db.ref('users').get()
            .timeout(const Duration(seconds: 3));
      } on TimeoutException {
        debugPrint('Database request timed out');
        return [];
      }
      
      if (!snapshot.exists) {
        return [];
      }

      final Map<String, dynamic> users =
          Map<String, dynamic>.from(snapshot.value as Map);
      return users.entries
          .map((e) => {
                'uid': e.key,
                ...Map<String, dynamic>.from(e.value as Map),
              })
          .toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  // Get user details by UID
  Future<Map<String, dynamic>?> getUserByUID(String uid) async {
    try {
      final snapshot = await _db.ref('users/$uid').get();
      if (!snapshot.exists) {
        return null;
      }

      return {
        'uid': uid,
        ...Map<String, dynamic>.from(snapshot.value as Map),
      };
    } catch (e) {
      return null;
    }
  }

  // Update user status (suspend/ban/active)
  Future<void> updateUserStatus(String uid, String status) async {
    await _db.ref('users/$uid/status').set(status);
  }

  // Delete user — also removes the Firebase Auth account so the email can be reused
  Future<void> deleteUser(String uid, {String? email, String? storedPassword}) async {
    // Use a secondary Firebase app so the admin session is not affected
    if (email != null && storedPassword != null && storedPassword.isNotEmpty) {
      const secondaryName = '_zenno_user_deletion';
      FirebaseApp? secondary;
      try {
        try {
          secondary = Firebase.app(secondaryName);
        } catch (_) {
          secondary = await Firebase.initializeApp(
            name: secondaryName,
            options: Firebase.app().options,
          );
        }
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondary);
        await secondaryAuth.signInWithEmailAndPassword(
          email: email,
          password: storedPassword,
        );
        await secondaryAuth.currentUser?.delete();
      } catch (e) {
        debugPrint('Firebase Auth account deletion skipped: $e');
      } finally {
        try { await secondary?.delete(); } catch (_) {}
      }
    }
    await _db.ref('users/$uid').remove();
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final snapshot = await _db.ref('users').get();
      if (!snapshot.exists) {
        return null;
      }

      final users = Map<String, dynamic>.from(snapshot.value as Map);
      for (final entry in users.entries) {
        final userData = Map<String, dynamic>.from(entry.value as Map);
        if (userData['email'] == email) {
          return {
            'uid': entry.key,
            ...userData,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create or update user profile in database
  Future<bool> createUserProfile(String uid, Map<String, dynamic> userData) async {
    try {
      await _db.ref('users/$uid').set({
        ...userData,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Stream to listen for user changes
  Stream<Map<String, dynamic>?> getUserStream(String uid) {
    return _db
        .ref('users/$uid')
        .onValue
        .map((event) => event.snapshot.value != null
            ? Map<String, dynamic>.from(event.snapshot.value as Map)
            : null);
  }

  // Stream to listen for all users (for admin dashboard)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _db.ref('users').onValue.map((event) {
      if (!event.snapshot.exists) {
        return [];
      }

      final Map<String, dynamic> users =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      return users.entries
          .map((e) => {
                'uid': e.key,
                ...Map<String, dynamic>.from(e.value as Map),
              })
          .toList();
    });
  }

  // ── Admin Settings ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAdminSettings() async {
    try {
      final snap = await _db.ref('adminSettings').get();
      if (!snap.exists || snap.value == null) return {};
      return Map<String, dynamic>.from(snap.value as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveAdminSettings(Map<String, dynamic> settings) async {
    await _db.ref('adminSettings').update(settings);
  }

  Stream<Map<String, dynamic>> getAdminSettingsStream() {
    return _db.ref('adminSettings').onValue.map((event) {
      if (event.snapshot.value == null) return <String, dynamic>{};
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  Future<void> clearAllNotifications() async {
    await _db.ref('notifications').remove();
  }

  Future<int> resetSuspendedUsers() async {
    final users = await getAllUsers();
    int count = 0;
    for (final user in users) {
      final uid = (user['uid'] ?? '').toString();
      final status = (user['status'] ?? 'active').toString();
      if (uid.isNotEmpty && (status == 'suspended' || status == 'banned')) {
        await _db.ref('users/$uid/status').set('active');
        count++;
      }
    }
    return count;
  }

  Future<Map<String, dynamic>> getStoreStatistics() async {
    try {
      final snap = await _db.ref('users').get()
          .timeout(const Duration(seconds: 5));
      if (!snap.exists || snap.value == null) {
        return {'totalPurchases': 0, 'totalWalletBalance': 0.0, 'totalCards': 0};
      }
      final users = Map<String, dynamic>.from(snap.value as Map);
      int totalPurchases = 0;
      double totalWallet = 0.0;
      int totalCards = 0;
      for (final entry in users.entries) {
        final u = Map<String, dynamic>.from(entry.value as Map? ?? {});
        final purchases = u['purchases'] as Map?;
        final cards = u['cards'] as Map?;
        final wallet = (u['wallet'] as num?) ?? 0;
        totalPurchases += purchases?.length ?? 0;
        totalCards += cards?.length ?? 0;
        totalWallet += wallet.toDouble();
      }
      return {
        'totalPurchases': totalPurchases,
        'totalWalletBalance': totalWallet,
        'totalCards': totalCards,
      };
    } catch (_) {
      return {'totalPurchases': 0, 'totalWalletBalance': 0.0, 'totalCards': 0};
    }
  }

  // Get user statistics (total users, active users, etc.)
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      // Add a timeout to prevent hanging indefinitely
      final users = await getAllUsers().timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );
      
      int activeUsers = 0;
      int suspendedUsers = 0;
      int bannedUsers = 0;

      for (final user in users) {
        final status = user['status'] ?? 'active';
        if (status == 'active') {
          activeUsers++;
        } else if (status == 'suspended') {
          suspendedUsers++;
        } else if (status == 'banned') {
          bannedUsers++;
        }
      }

      return {
        'totalUsers': users.length,
        'activeUsers': activeUsers,
        'suspendedUsers': suspendedUsers,
        'bannedUsers': bannedUsers,
      };
    } catch (e) {
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'suspendedUsers': 0,
        'bannedUsers': 0,
      };
    }
  }
}
