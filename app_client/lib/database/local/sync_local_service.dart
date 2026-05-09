import 'dart:convert';
import '../database_service.dart';

class SyncLocalService {
  static Future<void> enqueueOfflineOperation({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final db = await DatabaseService.database;
    await db.insert('sync_queue', {
      'endpoint':   endpoint,
      'method':     method,
      'body':       body != null ? jsonEncode(body) : null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await DatabaseService.database;
    return db.query('sync_queue', orderBy: 'created_at ASC');
  }

  static Future<void> removeOperation(int id) async {
    final db = await DatabaseService.database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearSyncQueue() async {
    final db = await DatabaseService.database;
    await db.delete('sync_queue');
  }
}
