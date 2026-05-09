import '../database_service.dart';
import '../../models/user_model.dart';

class SessionLocalService {
  static Future<void> saveSession(User user, String token) async {
    final db = await DatabaseService.database;
    await db.delete('session');
    await db.insert('session', {
      'user_id':    user.id,
      'username':   user.username,
      'names':      user.names,
      'lastnames':  user.lastnames,
      'email':      user.email,
      'phone':      user.phone,
      'role':       user.role,
      'token':      token,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final db   = await DatabaseService.database;
    final rows = await db.query('session', limit: 1);
    return rows.isNotEmpty ? rows.first : null;
  }

  static Future<void> clearSession() async {
    final db = await DatabaseService.database;
    await db.delete('session');
  }
}
