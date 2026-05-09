class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double cost;
  final String category;
  final String brand;
  final String model;
  final String sku;
  final String warranty;
  final String status; // available | out_of_stock | discontinued
  final int stock;
  final int minStock;
  final List<String> images;
  final Map<String, dynamic> specs;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.category,
    required this.brand,
    required this.model,
    required this.sku,
    required this.warranty,
    required this.status,
    required this.stock,
    required this.minStock,
    required this.images,
    required this.specs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // images puede venir como lista o como campo "image" string
    List<String> parseImages() {
      final raw = json['images'];
      if (raw is List && raw.isNotEmpty) {
        return List<String>.from(raw.map((e) => e.toString()));
      }
      final single = json['image'];
      if (single is String && single.isNotEmpty) return [single];
      return [];
    }

    return Product(
      id:          json['id']          ?? '',
      name:        json['name']        ?? '',
      description: json['description'] ?? '',
      price:       (json['price']    as num?)?.toDouble() ?? 0.0,
      cost:        (json['cost']     as num?)?.toDouble() ?? 0.0,
      category:    json['category']   ?? '',
      brand:       json['brand']      ?? '',
      model:       json['model']      ?? '',
      sku:         json['sku']        ?? '',
      warranty:    json['warranty']   ?? '',
      status:      json['status']     ?? 'available',
      stock:       (json['stock']    as num?)?.toInt() ?? 0,
      minStock:    (json['minStock'] as num?)?.toInt() ?? 0,
      images:      parseImages(),
      specs:       (json['specs'] is Map)
          ? Map<String, dynamic>.from(json['specs'])
          : {},
    );
  }

  bool get isAvailable => status == 'available' && stock > 0;
  bool get isLowStock  => stock > 0 && stock <= minStock;
  String get firstImage => images.isNotEmpty ? images[0] : '';
}