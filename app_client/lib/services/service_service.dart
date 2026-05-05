import '../models/service_model.dart';
import 'api_service.dart';

class ServiceService {
  final ApiService api;

  ServiceService(this.api);

  Future<List<ServiceModel>> getServices() async {
    final response = await api.get('/services');

    final data = response is List ? response : (response['data'] ?? []);

    return List<ServiceModel>.from(
      data.map((item) => ServiceModel.fromJson(item)),
    );
  }
}