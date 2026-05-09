import '../models/service_model.dart';
import '../database/local/service_local_service.dart';
import 'api_service.dart';

class ServiceService {
  final ApiService api;

  ServiceService(this.api);

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await api.get('/services');

      final data = response is List
      ? response
          : (response['data'] ?? []);

      final services = List<ServiceModel>.from(
        data.map((item) => ServiceModel.fromJson(item)),
      );

      await ServiceLocalService.cacheServices(services);

      return services;

    } catch (e) {

    print('Error obteniendo servicios: $e');

    final cachedServices = await ServiceLocalService.getCachedServices();

    if (cachedServices.isNotEmpty) {
      return cachedServices;
    }

    rethrow;
    }
  }

  Future<ServiceModel> createService(ServiceModel service) async {
  final response = await api.post('/services', {
  'name':        service.name,
  'description': service.description,
  'price':       service.price,
  'duration':    service.duration,
  'active':      service.active,
  });

  return ServiceModel.fromJson(response);
  }

  Future<ServiceModel> updateService(
  String id,
  ServiceModel service,
  ) async {

  final response = await api.put('/services/$id', {
  'name':        service.name,
  'description': service.description,
  'price':       service.price,
  'duration':    service.duration,
  'active':      service.active,
  });

  return ServiceModel.fromJson(response);
  }

  Future<void> deleteService(String id) async {
  await api.delete('/services/$id');
  }
}
