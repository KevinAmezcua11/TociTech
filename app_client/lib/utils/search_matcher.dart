import '../models/product_model.dart';
import '../models/service_model.dart';

class SearchMatcher {
  const SearchMatcher._();

  static String normalize(String value) {
    return value.trim().toLowerCase();
  }

  static bool hasValidQuery(String query) {
    return normalize(query).isNotEmpty;
  }

  static bool productMatches(Product product, String query) {
    final term = normalize(query);
    if (term.isEmpty) return false;

    final searchableValues = <String>[
      product.name,
      product.category,
      product.description,
      product.brand,
      product.model,
      product.sku,
      ...product.specs.keys,
      ...product.specs.values.map((value) => value.toString()),
    ];

    return searchableValues.any((value) => normalize(value).contains(term));
  }

  static bool serviceMatches(ServiceModel service, String query) {
    final term = normalize(query);
    if (term.isEmpty) return false;

    final searchableValues = <String>[
      service.name,
      service.description,
      service.duration,
    ];

    return searchableValues.any((value) => normalize(value).contains(term));
  }
}
