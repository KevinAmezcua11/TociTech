import 'package:flutter/foundation.dart';
import '../database_service.dart';
import '../local/session_local_service.dart';
import '../../models/product_model.dart';

class CartLocalService {
  static final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);

  static Future<void> refreshCount() async {
    countNotifier.value = await getCartItemCount();
  }

  static Future<String?> _userId() async {
    final session = await SessionLocalService.getSession();
    return session?['user_id'] as String?;
  }

  static Future<void> addToCart(Product product, {int quantity = 1}) async {
    final userId = await _userId();
    if (userId == null) return;

    final db       = await DatabaseService.database;
    final existing = await db.query(
      'carrito',
      where:     'product_id = ? AND user_id = ?',
      whereArgs: [product.id, userId],
    );

    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        'carrito',
        {'quantity': currentQty + quantity},
        where:     'product_id = ? AND user_id = ?',
        whereArgs: [product.id, userId],
      );
    } else {
      await db.insert('carrito', {
        'user_id':       userId,
        'product_id':    product.id,
        'product_name':  product.name,
        'product_price': product.price,
        'product_image': product.firstImage,
        'quantity':      quantity,
        'added_at':      DateTime.now().toIso8601String(),
      });
    }
    await refreshCount();
  }

  static Future<List<Map<String, dynamic>>> getCart() async {
    final userId = await _userId();
    if (userId == null) return [];
    final db = await DatabaseService.database;
    return db.query(
      'carrito',
      where:     'user_id = ?',
      whereArgs: [userId],
      orderBy:   'added_at ASC',
    );
  }

  static Future<double> getCartTotal() async {
    final userId = await _userId();
    if (userId == null) return 0.0;
    final db     = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(product_price * quantity) as total FROM carrito WHERE user_id = ?',
      [userId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<int> getCartItemCount() async {
    final userId = await _userId();
    if (userId == null) return 0;
    final db     = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM carrito WHERE user_id = ?',
      [userId],
    );
    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  static Future<void> updateCartQuantity(int cartId, int quantity) async {
    final db = await DatabaseService.database;
    if (quantity <= 0) {
      await db.delete('carrito', where: 'id = ?', whereArgs: [cartId]);
    } else {
      await db.update(
        'carrito',
        {'quantity': quantity},
        where:     'id = ?',
        whereArgs: [cartId],
      );
    }
    await refreshCount();
  }

  static Future<void> removeFromCart(int cartId) async {
    final db = await DatabaseService.database;
    await db.delete('carrito', where: 'id = ?', whereArgs: [cartId]);
    await refreshCount();
  }

  static Future<void> clearCart() async {
    final userId = await _userId();
    final db     = await DatabaseService.database;
    if (userId != null) {
      await db.delete('carrito', where: 'user_id = ?', whereArgs: [userId]);
    }
    await refreshCount();
  }
}
