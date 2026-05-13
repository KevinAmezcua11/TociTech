import 'package:flutter_test/flutter_test.dart';
import 'package:tocitech/models/product_model.dart';
import 'package:tocitech/models/service_model.dart';
import 'package:tocitech/utils/search_matcher.dart';

void main() {
  group('SearchMatcher', () {
    final product = Product(
      id: 'p1',
      name: 'Laptop Gamer Lenovo',
      description: 'Equipo para gaming y edicion',
      price: 16500,
      cost: 12000,
      category: 'Hardware',
      brand: 'Lenovo',
      model: 'Legion',
      sku: 'LNV-LEG-001',
      warranty: '12 meses',
      status: 'available',
      stock: 4,
      minStock: 1,
      images: const [],
      specs: const {'ram': '16 GB'},
    );

    const service = ServiceModel(
      id: 's1',
      name: 'Reparacion de laptop',
      description: 'Diagnostico y mantenimiento preventivo',
      price: 450,
      duration: '24 horas',
      active: true,
    );

    test('rejects empty and whitespace-only queries', () {
      expect(SearchMatcher.hasValidQuery(''), isFalse);
      expect(SearchMatcher.hasValidQuery('   '), isFalse);
    });

    test('matches products by relevant fields', () {
      expect(SearchMatcher.productMatches(product, 'laptop'), isTrue);
      expect(SearchMatcher.productMatches(product, 'hardware'), isTrue);
      expect(SearchMatcher.productMatches(product, 'gaming'), isTrue);
      expect(SearchMatcher.productMatches(product, '16 gb'), isTrue);
      expect(SearchMatcher.productMatches(product, 'impresora'), isFalse);
      expect(SearchMatcher.productMatches(product, '   '), isFalse);
    });

    test('matches services by relevant fields', () {
      expect(SearchMatcher.serviceMatches(service, 'reparacion'), isTrue);
      expect(SearchMatcher.serviceMatches(service, 'mantenimiento'), isTrue);
      expect(SearchMatcher.serviceMatches(service, '24 horas'), isTrue);
      expect(SearchMatcher.serviceMatches(service, 'mouse'), isFalse);
      expect(SearchMatcher.serviceMatches(service, '   '), isFalse);
    });
  });
}
