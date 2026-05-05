class ServiceModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final int? days;
  final String? state;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.days,
    this.state,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      days: json['days'],
      state: json['state'],
    );
  }
}