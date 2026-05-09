import '../database_service.dart';
import '../../models/product_model.dart';

class CartLocalService {
  static Future<void> addToCart(Product product, {int quantity = 1}) async {
    final db       = await DatabaseService.database;
    final existing = await db.query(
      'carrito',
      where:     'product_id = ?',
      whereArgs: [product.id],
    );

    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        'carrito',
        {'quantity': currentQty + quantity},
        where:     'product_id = ?',
        whereArgs: [product.id],
      );
    } else {
      await db.insert('carrito', {
        'product_id':    product.id,
        'product_name':  product.name,
        'product_price': product.price,
        'product_image': product.firstImage,
        'quantity':      quantity,
        'added_at':      DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getCart() async {
    final db = await DatabaseService.database;
    return db.query('carrito', orderBy: 'added_at ASC');
  }

  static Future<double> getCartTotal() async {
    final db     = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(product_price * quantity) as total FROM carrito',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<int> getCartItemCount() async {
    final db     = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM carrito',
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
  }

  static Future<void> removeFromCart(int cartId) async {
    final db = await DatabaseService.database;
    await db.delete('carrito', where: 'id = ?', whereArgs: [cartId]);
  }

  static Future<void> clearCart() async {
    final db = await DatabaseService.database;
    await db.delete('carrito');
  }
}
