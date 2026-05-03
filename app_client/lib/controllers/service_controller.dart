import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceController {
  final ServiceService serviceService;

  List<ServiceModel> services = [];
  bool isLoading = false;
  String? errorMessage;

  ServiceController(this.serviceService);

  Future<void> fetchServices() async {
    try {
      isLoading = true;
      errorMessage = null;

      final result = await serviceService.getServices();
      services = result;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
    }
  }
}