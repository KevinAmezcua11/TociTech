class Order {
  final String id;
  final String type;
  final String status;
  final double? total;

  Order({
    required this.id,
    required this.type,
    required this.status,
    this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}