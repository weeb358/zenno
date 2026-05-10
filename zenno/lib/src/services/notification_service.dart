import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  final FirebaseDatabase _db;

  NotificationService(this._db);

  DatabaseReference get _ref => _db.ref('notifications');

  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    return _ref.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      final list = map.entries.map((e) => {
        'id': e.key,
        ...Map<String, dynamic>.from(e.value as Map),
      }).toList();
      list.sort((a, b) =>
          ((b['createdAt'] as int?) ?? 0).compareTo((a['createdAt'] as int?) ?? 0));
      return list;
    });
  }

  Future<String> addNotification(Map<String, dynamic> data) async {
    final newRef = _ref.push();
    await newRef.set({
      ...data,
      'id': newRef.key,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
    return newRef.key ?? '';
  }

  Future<void> deleteNotification(String id) async {
    await _ref.child(id).remove();
  }
}
