import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration;
  final bool active;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.active,
  });

  factory ServiceModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return ServiceModel(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0,
      duration: (data['duration'] ?? '').toString(),
      active: data['active'] != false,
    );
  }

  Map<String, dynamic> toFirestore({bool includeCreatedAt = false}) {
    final cleanName = name.trim();
    final data = <String, dynamic>{
      'name': cleanName,
      'nameKey': cleanName.toLowerCase(),
      'description': description.trim(),
      'price': price,
      'duration': duration.trim(),
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (includeCreatedAt) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    return data;
  }
}
