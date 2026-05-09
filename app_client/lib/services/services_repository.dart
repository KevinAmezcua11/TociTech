import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_model.dart';
import 'firebase_bootstrap.dart';

class ServicesRepository {
  ServicesRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('services');

  Stream<List<ServiceModel>> watchServices() {
    if (!FirebaseBootstrap.isInitialized) {
      return Stream.error(
        FirebaseBootstrap.error ??
            Exception('Firebase no esta configurado en la app cliente.'),
      );
    }

    return _collection.snapshots().map((snapshot) {
      final services = snapshot.docs.map(ServiceModel.fromDoc).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return services;
    });
  }

  Future<void> createService(ServiceModel service) async {
    _validateService(service);
    await _ensureUniqueName(service.name);
    await _collection.add(service.toFirestore(includeCreatedAt: true));
  }

  Future<void> updateService(ServiceModel service) async {
    _validateService(service);
    await _ensureUniqueName(service.name, currentId: service.id);
    await _collection.doc(service.id).update(service.toFirestore());
  }

  Future<void> deleteService(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('No se encontro el servicio a eliminar.');
    }

    await _collection.doc(id).delete();
  }

  Future<void> _ensureUniqueName(String name, {String? currentId}) async {
    final snapshot = await _collection
        .where('nameKey', isEqualTo: name.trim().toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return;
    if (currentId != null && snapshot.docs.first.id == currentId) return;

    throw ArgumentError('Ya existe un servicio con ese nombre.');
  }

  void _validateService(ServiceModel service) {
    if (service.name.trim().isEmpty) {
      throw ArgumentError('El nombre del servicio es obligatorio.');
    }
    if (service.description.trim().isEmpty) {
      throw ArgumentError('La descripcion del servicio es obligatoria.');
    }
    if (service.duration.trim().isEmpty) {
      throw ArgumentError('La duracion del servicio es obligatoria.');
    }
    if (service.price.isNaN || service.price < 0) {
      throw ArgumentError('El precio debe ser un numero valido mayor o igual a cero.');
    }
  }
}
