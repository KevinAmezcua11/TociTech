class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      );
}

class OrderServiceInfo {
  final String serviceId;
  final String name;
  final double basePrice;

  const OrderServiceInfo({
    required this.serviceId,
    required this.name,
    required this.basePrice,
  });

  factory OrderServiceInfo.fromJson(Map<String, dynamic> json) => OrderServiceInfo(
        serviceId: json['serviceId'] ?? '',
        name: json['name'] ?? '',
        basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      );
}

class Order {
  final String id;
  final String type;
  final String estadoPedido;
  final String? estadoPago;
  final String? paymentIntentId;
  final double? total;
  final Map<String, dynamic>? customer;
  final List<OrderItem> items;
  final OrderServiceInfo? service;
  final String? equipment;
  final String? problem;
  final DateTime? createdAt;
  final DateTime? paidAt;

  const Order({
    required this.id,
    required this.type,
    required this.estadoPedido,
    this.estadoPago,
    this.paymentIntentId,
    this.total,
    this.customer,
    this.items = const [],
    this.service,
    this.equipment,
    this.problem,
    this.createdAt,
    this.paidAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      estadoPedido: json['estadoPedido'] ?? 'PENDIENTE',
      estadoPago: json['estadoPago'],
      paymentIntentId: json['paymentIntentId'],
      total: (json['total'] as num?)?.toDouble(),
      customer: json['customer'] as Map<String, dynamic>?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      service: json['service'] != null
          ? OrderServiceInfo.fromJson(json['service'] as Map<String, dynamic>)
          : null,
      equipment: json['equipment'],
      problem: json['problem'],
      createdAt: _parseDate(json['createdAt']),
      paidAt: _parseDate(json['paidAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    if (v is Map && v['_seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch((v['_seconds'] as int) * 1000);
    }
    return null;
  }
}
