import '../database/local/notification_local_service.dart';
import '../models/order_model.dart';

class OrderNotificationSyncService {
  const OrderNotificationSyncService._();

  static Future<void> syncPurchaseNotifications(
    List<Order> orders, {
    required String userId,
  }) async {
    final productOrders = orders.where((order) => order.type == 'product');

    for (final order in productOrders) {
      if (_isApproved(order)) {
        await NotificationLocalService.saveNotification(
          userId: userId,
          id: 'order-${order.id}-approved',
          title: 'Compra aprobada',
          message:
              'Tu compra ${_orderLabel(order)} fue aprobada correctamente.',
          type: 'purchase_approved',
          data: {
            'orderId': order.id,
            'estadoPedido': order.estadoPedido,
            'estadoPago': order.estadoPago,
          },
        );
      }

      if (_isCancelled(order)) {
        await NotificationLocalService.saveNotification(
          userId: userId,
          id: 'order-${order.id}-cancelled',
          title: 'Compra cancelada',
          message:
              'Tu compra ${_orderLabel(order)} fue cancelada. Revisa el detalle en Mis pedidos.',
          type: 'purchase_cancelled',
          data: {
            'orderId': order.id,
            'estadoPedido': order.estadoPedido,
            'estadoPago': order.estadoPago,
          },
        );
      }
    }
  }

  static bool _isApproved(Order order) {
    return order.estadoPago == 'PAGADO' || order.estadoPedido == 'COMPLETADO';
  }

  static bool _isCancelled(Order order) {
    return order.estadoPedido == 'CANCELADO' || order.estadoPago == 'FALLIDO';
  }

  static String _orderLabel(Order order) {
    if (order.items.isEmpty) {
      final shortId = order.id.length <= 6
          ? order.id
          : order.id.substring(0, 6);
      return shortId.isEmpty ? 'registrada' : '#$shortId';
    }

    final firstItem = order.items.first.name;
    if (order.items.length == 1) return 'de $firstItem';

    return 'de $firstItem y ${order.items.length - 1} producto${order.items.length == 2 ? '' : 's'} mas';
  }
}
