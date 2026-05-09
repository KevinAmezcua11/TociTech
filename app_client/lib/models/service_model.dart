class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration;
  final String image;
  final bool active;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.active,
    this.image = '',
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id:          json['id']          ?? '',
      name:        json['name']        ?? '',
      description: json['description'] ?? '',
      price:       (json['price']    as num?)?.toDouble() ?? 0.0,
      duration:    json['duration']   ?? '',
      image:       json['image']      ?? '',
      active:      json['active']     != false,
    );
  }

  bool get hasImage => image.isNotEmpty;
  bool get isActive => active;
}
