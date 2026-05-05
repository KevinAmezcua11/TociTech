import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController {
  final ProductService productService;

  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;

  ProductController(this.productService);

  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      errorMessage = null;

      final result = await productService.getProducts();

      products = result;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
    }
  }
}