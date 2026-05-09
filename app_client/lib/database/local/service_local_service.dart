import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../../models/service_model.dart';

class ServiceLocalService {
  static Future<void> cacheServices(List<ServiceModel> services) async {
    final db    = await DatabaseService.database;
    final batch = db.batch();
    final now   = DateTime.now().toIso8601String();

    for (final s in services) {
      batch.insert(
        'servicios_cache',
        {
          'id':          s.id,
          'name':        s.name,
          'description': s.description,
          'price':       s.price,
          'duration':    s.duration,
          'image':       s.image,
          'active':      s.active ? 1 : 0,
          'cached_at':   now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<ServiceModel>> getCachedServices() async {
    final db   = await DatabaseService.database;
    final rows = await db.query('servicios_cache');
    return rows.map(_rowToService).toList();
  }

  static Future<List<ServiceModel>> getCachedActiveServices() async {
    final db   = await DatabaseService.database;
    final rows = await db.query(
      'servicios_cache',
      where:     'active = ?',
      whereArgs: [1],
    );
    return rows.map(_rowToService).toList();
  }

  static Future<void> clearServiceCache() async {
    final db = await DatabaseService.database;
    await db.delete('servicios_cache');
  }

  static ServiceModel _rowToService(Map<String, dynamic> row) {
    return ServiceModel(
      id:          row['id']          as String,
      name:        row['name']        as String? ?? '',
      description: row['description'] as String? ?? '',
      price:       (row['price']    as num?)?.toDouble() ?? 0.0,
      duration:    row['duration']   as String? ?? '',
      image:       row['image']      as String? ?? '',
      active:      (row['active']   as int?) == 1,
    );
  }
}
