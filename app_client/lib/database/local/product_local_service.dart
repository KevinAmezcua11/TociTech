import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../../models/product_model.dart';

class ProductLocalService {
  static Future<void> cacheProducts(List<Product> products) async {
    final db    = await DatabaseService.database;
    final batch = db.batch();
    final now   = DateTime.now().toIso8601String();

    for (final p in products) {
      batch.insert(
        'productos_cache',
        {
          'id':          p.id,
          'name':        p.name,
          'description': p.description,
          'price':       p.price,
          'cost':        p.cost,
          'category':    p.category,
          'brand':       p.brand,
          'model':       p.model,
          'sku':         p.sku,
          'warranty':    p.warranty,
          'status':      p.status,
          'stock':       p.stock,
          'min_stock':   p.minStock,
          'images':      jsonEncode(p.images),
          'specs':       jsonEncode(p.specs),
          'cached_at':   now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Product>> getCachedProducts() async {
    final db   = await DatabaseService.database;
    final rows = await db.query('productos_cache');
    return rows.map(_rowToProduct).toList();
  }

  static Future<List<Product>> getCachedProductsByCategory(String category) async {
    final db   = await DatabaseService.database;
    final rows = await db.query(
      'productos_cache',
      where:     'category = ?',
      whereArgs: [category],
    );
    return rows.map(_rowToProduct).toList();
  }

  static Future<void> clearProductCache() async {
    final db = await DatabaseService.database;
    await db.delete('productos_cache');
  }

  static Product _rowToProduct(Map<String, dynamic> row) {
    return Product(
      id:          row['id']          as String,
      name:        row['name']        as String? ?? '',
      description: row['description'] as String? ?? '',
      price:       (row['price']    as num?)?.toDouble() ?? 0.0,
      cost:        (row['cost']     as num?)?.toDouble() ?? 0.0,
      category:    row['category']   as String? ?? '',
      brand:       row['brand']      as String? ?? '',
      model:       row['model']      as String? ?? '',
      sku:         row['sku']        as String? ?? '',
      warranty:    row['warranty']   as String? ?? '',
      status:      row['status']     as String? ?? 'available',
      stock:       (row['stock']    as num?)?.toInt() ?? 0,
      minStock:    (row['min_stock'] as num?)?.toInt() ?? 0,
      images: List<String>.from(
        jsonDecode(row['images'] as String? ?? '[]'),
      ),
      specs: Map<String, dynamic>.from(
        jsonDecode(row['specs'] as String? ?? '{}'),
      ),
    );
  }
}
