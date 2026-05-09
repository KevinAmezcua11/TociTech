import '../models/product_model.dart';
import '../database/local/product_local_service.dart';
import 'api_service.dart';

class ProductService {
  final ApiService api;

  ProductService(this.api);

  Future<List<Product>> getProducts() async {
    try {
      final response = await api.get('/products');

      final data = response is List
      ? response
          : (response['data'] ?? []);

      final products = List<Product>.from(
        data.map((item) => Product.fromJson(item)),
      );

      await ProductLocalService.cacheProducts(products);

      return products;

    } catch (e) {
      final cachedProducts = await ProductLocalService.getCachedProducts();

      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }

      rethrow;
    }
  }
}
