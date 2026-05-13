import 'package:flutter_test/flutter_test.dart';
import 'package:tocitech/services/home_summary_service.dart';

void main() {
  group('HomeSummary', () {
    test('parses numeric counters from json', () {
      final summary = HomeSummary.fromJson({
        'clients': 12,
        'services': 5,
        'products': 18,
      });

      expect(summary.clients, 12);
      expect(summary.services, 5);
      expect(summary.products, 18);
    });

    test('falls back to zero when counters are missing', () {
      final summary = HomeSummary.fromJson({});

      expect(summary.clients, 0);
      expect(summary.services, 0);
      expect(summary.products, 0);
    });
  });
}
