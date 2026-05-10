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
      'bannerUrl': game['bannerUrl'] ?? '',
      'category': game['category'] ?? '',
      'developer': game['developer'] ?? '',
      'discount': game['discount'] ?? 0,
      'currency': game['currency'] ?? 'USD',
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
      'bannerUrl': game['bannerUrl'] ?? '',
      'category': game['category'] ?? '',
      'developer': game['developer'] ?? '',
      'discount': game['discount'] ?? 0,
      'currency': game['currency'] ?? 'USD',
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
  Future<void> savePurchase(String gameName, String gamePrice,
      {String bannerUrl = ''}) async {
    final uid = _uid;
    if (uid == null) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.ref('users/$uid/purchases/$id').set({
      'name': gameName,
      'price': gamePrice,
      'bannerUrl': bannerUrl,
      'purchasedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeFromLibrary(String purchaseId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.ref('users/$uid/purchases/$purchaseId').remove();
  }

  // ── Cards ─────────────────────────────────────────────────────
  Future<void> saveCard(Map<String, dynamic> card) async {
    final uid = _uid;
    if (uid == null) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.ref('users/$uid/cards/$id').set({
      'id': id,
      'cardholderName': card['cardholderName'] ?? '',
      'cardLast4': card['cardLast4'] ?? '',
      'expiry': card['expiry'] ?? '',
      'type': card['type'] ?? 'credit',
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeCard(String cardId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.ref('users/$uid/cards/$cardId').remove();
  }

  Stream<List<Map<String, dynamic>>> getCardsStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db.ref('users/$uid/cards').onValue.map((event) {
      if (event.snapshot.value == null) return <Map<String, dynamic>>[];
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final list = raw.entries.map((e) {
        final item = Map<String, dynamic>.from(e.value as Map);
        item['id'] = e.key;
        return item;
      }).toList();
      list.sort((a, b) =>
          ((a['addedAt'] as int?) ?? 0).compareTo((b['addedAt'] as int?) ?? 0));
      return list;
    });
  }

  Future<bool> deductFromWallet(double amount) async {
    final uid = _uid;
    if (uid == null) return false;
    final walletRef = _db.ref('users/$uid/wallet');
    bool success = false;
    await walletRef.runTransaction((currentData) {
      final current = ((currentData as num?) ?? 0).toDouble();
      if (current < amount) return Transaction.abort();
      success = true;
      return Transaction.success((current - amount).clamp(0, double.infinity));
    });
    return success;
  }

  Future<void> addToWallet(double amount, {String cardLast4 = ''}) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = _db.ref('users/$uid/wallet');
    final snap = await ref.get();
    final current = ((snap.value as num?) ?? 0).toDouble();
    await ref.set((current + amount).clamp(0, double.infinity));

    final txnId = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.ref('users/$uid/walletTransactions/$txnId').set({
      'amount': amount,
      'cardLast4': cardLast4,
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<Map<String, dynamic>>> getWalletTransactionsStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db.ref('users/$uid/walletTransactions').onValue.map((event) {
      if (event.snapshot.value == null) return <Map<String, dynamic>>[];
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final list = raw.entries.map((e) {
        final item = Map<String, dynamic>.from(e.value as Map);
        item['id'] = e.key;
        return item;
      }).toList();
      list.sort((a, b) => ((b['addedAt'] as int?) ?? 0)
          .compareTo((a['addedAt'] as int?) ?? 0));
      return list;
    });
  }

  // ── User Settings ─────────────────────────────────────────
  Future<Map<String, dynamic>> getSettings() async {
    final uid = _uid;
    if (uid == null) return {};
    try {
      final snap = await _db.ref('users/$uid/settings').get();
      if (snap.value == null) return {};
      return Map<String, dynamic>.from(snap.value as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.ref('users/$uid/settings').update(settings);
  }

  Stream<Map<String, dynamic>> getSettingsStream() {
    final uid = _uid;
    if (uid == null) return Stream.value({});
    return _db.ref('users/$uid/settings').onValue.map((event) {
      if (event.snapshot.value == null) return <String, dynamic>{};
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  // ── Purchase History ──────────────────────────────────────
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
