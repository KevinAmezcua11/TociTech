import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';

class NotificationLocalService {
  static Future<void> saveNotification({
    required String userId,
    required String id,
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    final db = await DatabaseService.database;
    await db.insert(
      'notificaciones',
      {
        'id':         id,
        'user_id':    userId,
        'title':      title,
        'message':    message,
        'type':       type,
        'leida':      0,
        'created_at': DateTime.now().toIso8601String(),
        'data':       data != null ? jsonEncode(data) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final db = await DatabaseService.database;
    return db.query(
      'notificaciones',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  static Future<List<Map<String, dynamic>>> getUnreadNotifications(String userId) async {
    final db = await DatabaseService.database;
    return db.query(
      'notificaciones',
      where: 'user_id = ? AND leida = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  static Future<List<Map<String, dynamic>>> getReadNotifications(String userId) async {
    final db = await DatabaseService.database;
    return db.query(
      'notificaciones',
      where: 'user_id = ? AND leida = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  static Future<int> getUnreadCount(String userId) async {
    final db     = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notificaciones WHERE user_id = ? AND leida = 0',
      [userId],
    );
    return (result.first['count'] as num?)?.toInt() ?? 0;
  }

  static Future<void> markNotificationRead(String id) async {
    final db = await DatabaseService.database;
    await db.update(
      'notificaciones',
      {'leida': 1},
      where:     'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> markAllNotificationsRead(String userId) async {
    final db = await DatabaseService.database;
    await db.update(
      'notificaciones',
      {'leida': 1},
      where:     'user_id = ?',
      whereArgs: [userId],
    );
  }

  static Future<void> deleteNotification(String id) async {
    final db = await DatabaseService.database;
    await db.delete('notificaciones', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteUserNotifications(String userId) async {
    final db = await DatabaseService.database;
    await db.delete('notificaciones', where: 'user_id = ?', whereArgs: [userId]);
  }
}
