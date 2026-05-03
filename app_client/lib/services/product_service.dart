import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  final ApiService api;

  ProductService(this.api);

  Future<List<Product>> getProducts() async {
    final response = await api.get('/products');

    final data = response is List
        ? response
        : (response['data'] ?? []);

    return List<Product>.from(
      data.map((item) => Product.fromJson(item)),
    );
  }
}