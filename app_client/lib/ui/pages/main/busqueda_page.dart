import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import '../../../models/service_model.dart';
import '../../../services/api_service.dart';
import '../../../services/product_service.dart';
import '../../../services/service_service.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/search_matcher.dart';
import '../products/product_detail_page.dart';
import '../services/service_detail_page.dart';

class BusquedaPage extends StatefulWidget {
  const BusquedaPage({super.key});

  @override
  State<BusquedaPage> createState() => _BusquedaPageState();
}

class _BusquedaPageState extends State<BusquedaPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final ProductService _productService = ProductService(ApiService());
  final ServiceService _serviceService = ServiceService(ApiService());

  List<Product> _products = [];
  List<ServiceModel> _services = [];
  List<Product> _productResults = [];
  List<ServiceModel> _serviceResults = [];

  bool _loading = true;
  String _query = '';
  String? _friendlyError;

  bool get _hasQuery => SearchMatcher.hasValidQuery(_query);
  int get _resultCount => _productResults.length + _serviceResults.length;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
    _loadSearchData();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSearchData() async {
    setState(() {
      _loading = true;
      _friendlyError = null;
    });

    try {
      final results = await Future.wait([
        _productService.getProducts(),
        _serviceService.getServices(),
      ]);

      if (!mounted) return;

      _products = results[0] as List<Product>;
      _services = (results[1] as List<ServiceModel>)
          .where((service) => service.isActive)
          .toList();
      _applySearch();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _friendlyError =
            'No pudimos cargar el buscador. Revisa tu conexion e intenta de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onQueryChanged() {
    _query = _searchController.text;
    _applySearch();
  }

  void _applySearch() {
    final query = _searchController.text;

    setState(() {
      _query = query;

      if (!SearchMatcher.hasValidQuery(query)) {
        _productResults = [];
        _serviceResults = [];
        return;
      }

      _productResults = _products
          .where((product) => SearchMatcher.productMatches(product, query))
          .toList();
      _serviceResults = _services
          .where((service) => SearchMatcher.serviceMatches(service, query))
          .toList();
    });
  }

  void _applySuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.collapsed(
      offset: suggestion.length,
    );
    _searchFocus.requestFocus();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Buscador',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _loadSearchData,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const Text(
              'Encuentra lo que necesitas',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Busca productos y servicios por nombre, categoria o descripcion.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            _searchInput(),
            const SizedBox(height: 18),
            _suggestions(),
            const SizedBox(height: 24),
            _bodyContent(),
          ],
        ),
      ),
    );
  }

  Widget _searchInput() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        hintText: 'Buscar productos o servicios',
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        suffixIcon: _hasQuery
            ? IconButton(
                tooltip: 'Limpiar busqueda',
                onPressed: _clearSearch,
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textSecondary,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onSubmitted: (value) {
        if (!SearchMatcher.hasValidQuery(value)) {
          _clearSearch();
        }
      },
    );
  }

  Widget _suggestions() {
    const suggestions = [
      'Laptops',
      'Mouse',
      'Teclados',
      'Redes',
      'Hardware',
      'Reparacion',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: suggestions
          .map(
            (suggestion) => ActionChip(
              label: Text(suggestion),
              onPressed: () => _applySuggestion(suggestion),
              backgroundColor: AppColors.surface,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              labelStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _bodyContent() {
    if (_loading) {
      return const _SearchStateMessage(
        icon: Icons.manage_search_rounded,
        title: 'Cargando buscador',
        message: 'Estamos preparando productos y servicios disponibles.',
        showLoader: true,
      );
    }

    if (_friendlyError != null) {
      return _SearchStateMessage(
        icon: Icons.wifi_off_rounded,
        title: 'No se pudo buscar',
        message: _friendlyError!,
        actionLabel: 'Reintentar',
        onAction: _loadSearchData,
      );
    }

    if (!_hasQuery) {
      return const _SearchStateMessage(
        icon: Icons.search_rounded,
        title: 'Escribe una busqueda',
        message: 'No se aceptan busquedas vacias o solo con espacios.',
      );
    }

    if (_resultCount == 0) {
      return _SearchStateMessage(
        icon: Icons.search_off_rounded,
        title: 'Sin resultados',
        message:
            'No encontramos coincidencias para "${_query.trim()}". Prueba con otro nombre, categoria o descripcion.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_resultCount resultado${_resultCount == 1 ? '' : 's'} encontrado${_resultCount == 1 ? '' : 's'}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (_productResults.isNotEmpty) ...[
          const SizedBox(height: 18),
          _sectionTitle('Productos'),
          const SizedBox(height: 12),
          ..._productResults.map(_productResultCard),
        ],
        if (_serviceResults.isNotEmpty) ...[
          const SizedBox(height: 18),
          _sectionTitle('Servicios'),
          const SizedBox(height: 12),
          ..._serviceResults.map(_serviceResultCard),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _productResultCard(Product product) {
    final subtitle = [
      product.category,
      product.brand,
      product.model,
    ].where((value) => value.trim().isNotEmpty).join(' - ');

    return _ResultCard(
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.primary,
      title: product.name,
      subtitle: subtitle.isEmpty ? product.description : subtitle,
      detail: '\$${product.price.toStringAsFixed(0)} MXN',
      badge: product.isAvailable ? 'Disponible' : 'Sin stock',
      badgeColor: product.isAvailable ? AppColors.green : Colors.redAccent,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
    );
  }

  Widget _serviceResultCard(ServiceModel service) {
    return _ResultCard(
      icon: Icons.handyman_outlined,
      iconColor: AppColors.blue,
      title: service.name,
      subtitle: service.description,
      detail: '\$${service.price.toStringAsFixed(0)} MXN',
      badge: service.duration,
      badgeColor: AppColors.blue,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ServiceDetailPage(service: service)),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String detail;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _ResultCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isEmpty ? 'Sin nombre' : title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      if (subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            detail,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          _ResultBadge(text: badge, color: badgeColor),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _ResultBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text.isEmpty ? 'Disponible' : text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SearchStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool showLoader;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SearchStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.showLoader = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          if (showLoader)
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.4,
              ),
            )
          else
            Icon(icon, color: AppColors.primary, size: 34),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
