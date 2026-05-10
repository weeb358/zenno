import 'package:firebase_database/firebase_database.dart';

class GameService {
  final FirebaseDatabase _db;

  GameService(this._db);

  DatabaseReference get _gamesRef => _db.ref('games');

  Stream<List<Map<String, dynamic>>> getGamesStream({String? category}) {
    return _gamesRef.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return [];
      }

      final gamesMap = Map<String, dynamic>.from(event.snapshot.value as Map);
      final games = gamesMap.entries.map((entry) {
        return {
          'id': entry.key,
          ...Map<String, dynamic>.from(entry.value as Map),
        };
      }).toList();

      final filtered = games.where((game) {
        final status = (game['status'] ?? 'active').toString().toLowerCase();
        final gameCategory = (game['category'] ?? '').toString().toLowerCase();
        if (status != 'active') {
          return false;
        }
        if (category != null && category.isNotEmpty) {
          return gameCategory == category.toLowerCase();
        }
        return true;
      }).toList();

      filtered.sort((a, b) {
        final aCreated = (a['createdAt'] ?? 0) as int;
        final bCreated = (b['createdAt'] ?? 0) as int;
        return bCreated.compareTo(aCreated);
      });

      return filtered;
    });
  }

  Future<Map<String, dynamic>?> getGameById(String gameId) async {
    final snapshot = await _gamesRef.child(gameId).get();
    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    return {
      'id': gameId,
      ...Map<String, dynamic>.from(snapshot.value as Map),
    };
  }

  Future<String> addGame(Map<String, dynamic> data) async {
    final newRef = _gamesRef.push();
    await newRef.set({
      ...data,
      'id': newRef.key,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'status': data['status'] ?? 'active',
    });
    return newRef.key ?? '';
  }

  Future<void> updateGame(String gameId, Map<String, dynamic> data) async {
    await _gamesRef.child(gameId).update({
      ...data,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteGame(String gameId) async {
    await _gamesRef.child(gameId).remove();
  }

  // ── Upcoming Games ────────────────────────────────────────
  DatabaseReference get _upcomingRef => _db.ref('upcoming_games');

  Stream<List<Map<String, dynamic>>> getUpcomingGamesStream() {
    return _upcomingRef.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      final list = map.entries.map((e) => {
        'id': e.key,
        ...Map<String, dynamic>.from(e.value as Map),
      }).toList();
      list.sort((a, b) =>
          ((a['createdAt'] as int?) ?? 0).compareTo((b['createdAt'] as int?) ?? 0));
      return list;
    });
  }

  Future<String> addUpcomingGame(Map<String, dynamic> data) async {
    final newRef = _upcomingRef.push();
    await newRef.set({
      ...data,
      'id': newRef.key,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
    return newRef.key ?? '';
  }

  Future<void> updateUpcomingGame(String id, Map<String, dynamic> data) async {
    await _upcomingRef.child(id).update({
      ...data,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteUpcomingGame(String id) async {
    await _upcomingRef.child(id).remove();
  }

  /// Moves an upcoming game into the live games/ node and removes it from upcoming_games/.
  Future<void> releaseUpcomingGame(String id, Map<String, dynamic> data) async {
    await _gamesRef.child(id).set({
      'id': id,
      'name': data['name'] ?? '',
      'description': data['description'] ?? '',
      'price': data['price'] ?? '',
      'category': data['category'] ?? '',
      'status': 'active',
      'discount': data['discount'] ?? 0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
    await _upcomingRef.child(id).remove();
  }
}