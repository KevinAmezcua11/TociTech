import 'api_service.dart';

class HomeSummary {
  final int clients;
  final int services;
  final int products;

  const HomeSummary({
    required this.clients,
    required this.services,
    required this.products,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    return HomeSummary(
      clients: (json['clients'] as num?)?.toInt() ?? 0,
      services: (json['services'] as num?)?.toInt() ?? 0,
      products: (json['products'] as num?)?.toInt() ?? 0,
    );
  }

  HomeSummary copyWith({int? clients, int? services, int? products}) {
    return HomeSummary(
      clients: clients ?? this.clients,
      services: services ?? this.services,
      products: products ?? this.products,
    );
  }
}

class HomeSummaryService {
  final ApiService api;

  HomeSummaryService(this.api);

  Future<HomeSummary> getSummary() async {
    final response = await api.get('/home/summary');

    if (response is Map<String, dynamic>) {
      return HomeSummary.fromJson(response);
    }

    throw Exception('Respuesta invalida del resumen del home');
  }
}
