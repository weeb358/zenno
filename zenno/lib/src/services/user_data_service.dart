import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_database/firebase_database.dart';

class UserDataService {
  final fb.FirebaseAuth _auth;
  final FirebaseDatabase _db;

  UserDataService(this._auth, this._db);

  String? get _uid => _auth.currentUser?.uid;

  String _safeKey(String raw) =>
      raw.replaceAll(RegExp(r'[.\$#\[\]/]'), '_');

  // ── Wishlist ──────────────────────────────────────────────
  Future<void> addToWishlist(Map<String, dynamic> game) async {
    final uid = _uid;
    if (uid == null) return;
    final id = _safeKey((game['id'] ?? game['name'] ?? 'game').toString());
    await _db.ref('users/$uid/wishlist/$id').set({
      'id': game['id'] ?? id,
      'name': game['name'] ?? '',
      'price': game['price'] ?? '',
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeFromWishlist(String gameId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.ref('users/$uid/wishlist/${_safeKey(gameId)}').remove();
  }

  Future<bool> isInWishlist(String gameId) async {
    final uid = _uid;
    if (uid == null) return false;
    final snap = await _db.ref('users/$uid/wishlist/${_safeKey(gameId)}').get();
    return snap.exists;
  }

  Stream<List<Map<String, dynamic>>> getWishlistStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db.ref('users/$uid/wishlist').onValue.map((event) {
      if (event.snapshot.value == null) return <Map<String, dynamic>>[];
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      return raw.entries.map((e) {
        final item = Map<String, dynamic>.from(e.value as Map);
        item['id'] = e.key;
        return item;
      }).toList();
    });
  }

  // ── Cart ──────────────────────────────────────────────────
  Future<void> addToCart(Map<String, dynamic> game) async {
    final uid = _uid;
    if (uid == null) return;
    final id = _safeKey((game['id'] ?? game['name'] ?? 'game').toString());
    await _db.ref('users/$uid/cart/$id').set({
      'id': game['id'] ?? id,
      'name': game['name'] ?? '',
      'price': game['price'] ?? '',
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeFromCart(String gameId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.ref('users/$uid/cart/${_safeKey(gameId)}').remove();
  }

  Future<bool> isInCart(String gameId) async {
    final uid = _uid;
    if (uid == null) return false;
    final snap = await _db.ref('users/$uid/cart/${_safeKey(gameId)}').get();
    return snap.exists;
  }

  Stream<List<Map<String, dynamic>>> getCartStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db.ref('users/$uid/cart').onValue.map((event) {
      if (event.snapshot.value == null) return <Map<String, dynamic>>[];
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      return raw.entries.map((e) {
        final item = Map<String, dynamic>.from(e.value as Map);
        item['id'] = e.key;
        return item;
      }).toList();
    });
  }

  // ── Purchase History ──────────────────────────────────────
  Future<void> savePurchase(String gameName, String gamePrice) async {
    final uid = _uid;
    if (uid == null) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.ref('users/$uid/purchases/$id').set({
      'name': gameName,
      'price': gamePrice,
      'purchasedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<Map<String, dynamic>>> getPurchaseHistoryStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db.ref('users/$uid/purchases').onValue.map((event) {
      if (event.snapshot.value == null) return <Map<String, dynamic>>[];
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final list = raw.entries.map((e) {
        final item = Map<String, dynamic>.from(e.value as Map);
        item['id'] = e.key;
        return item;
      }).toList();
      list.sort((a, b) =>
          ((b['purchasedAt'] as int?) ?? 0)
              .compareTo((a['purchasedAt'] as int?) ?? 0));
      return list;
    });
  }
}
