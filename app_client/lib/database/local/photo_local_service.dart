import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoLocalService {
  static String _key(String userId) => 'photo_$userId';

  static Future<String?> getPhotoPath(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_key(userId));
    if (path == null) return null;
    if (!File(path).existsSync()) {
      await prefs.remove(_key(userId));
      return null;
    }
    return path;
  }

  /// Copies [sourcePath] to the app documents directory and saves the new path.
  /// Uses a timestamp in the filename so FileImage cache is always invalidated.
  /// Returns the persisted path.
  static Future<String> savePhoto(String userId, String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(sourcePath);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final dest = File(p.join(dir.path, 'profile_${userId}_$ts${ext.isEmpty ? ".jpg" : ext}'));
    await File(sourcePath).copy(dest.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), dest.path);
    return dest.path;
  }

  static Future<void> clearPhoto(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }
}
