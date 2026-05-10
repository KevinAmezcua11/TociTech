import '../database/local/cart_local_service.dart';
import '../models/product_model.dart';

class CartController {
  List<Map<String, dynamic>> items = [];
  int itemCount = 0;
  double total = 0.0;
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    try {
      items = await CartLocalService.getCart();
      itemCount = await CartLocalService.getCartItemCount();
      total = await CartLocalService.getCartTotal();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Future<void> add(Product product) async {
    await CartLocalService.addToCart(product);
    await load();
  }

  Future<void> updateQty(int cartId, int qty) async {
    await CartLocalService.updateCartQuantity(cartId, qty);
    await load();
  }

  Future<void> remove(int cartId) async {
    await CartLocalService.removeFromCart(cartId);
    await load();
  }

  Future<void> clear() async {
    await CartLocalService.clearCart();
    await load();
  }

  List<Map<String, dynamic>> get asPaymentItems => items
      .map((i) => {
            'productId': i['product_id'],
            'quantity': i['quantity'],
          })
      .toList();
}
