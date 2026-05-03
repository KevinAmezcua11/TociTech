import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderController {
  final OrderService orderService;

  List<Order> orders = [];
  bool isLoading = false;
  String? errorMessage;

  OrderController(this.orderService);

  Future<void> fetchOrders() async {
    try {
      isLoading = true;
      errorMessage = null;

      final result = await orderService.getOrders();
      orders = result;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
    }
  }

  Future<bool> createOrder(Map<String, dynamic> data) async {
    try {
      isLoading = true;
      errorMessage = null;

      await orderService.createOrder(data);

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
    }
  }
}