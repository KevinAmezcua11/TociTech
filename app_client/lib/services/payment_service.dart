import 'api_service.dart';

class PaymentService {
  final ApiService api;

  PaymentService(this.api);

  Future<Map<String, String>> createPaymentIntent(
      List<Map<String, dynamic>> items) async {
    final response = await api.post('/payments/create-payment-intent', {
      'items': items,
    });

    return {
      'clientSecret': response['clientSecret'] as String,
      'paymentIntentId': response['paymentIntentId'] as String,
    };
  }
}
