import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  final ApiService api;

  OrderService(this.api);

  Future<List<Order>> getOrders() async {
    final response = await api.get('/orders');

    final data = response is List ? response : (response['data'] ?? []);

    return List<Order>.from(
      data.map((item) => Order.fromJson(item)),
    );
  }

  Future<Order> createOrder(Map<String, dynamic> data) async {
    final response = await api.post('/orders', data);

    return Order.fromJson(response);
  }
}