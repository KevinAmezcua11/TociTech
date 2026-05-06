import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../../../services/api_service.dart';
import '../../widgets/product_card.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final ProductService _productService;

  List<Product> _allProducts  = [];
  List<Product> _filtered     = [];
  bool _loading               = true;
  String? _error;

  // Filtros
  String _ordenarPor            = 'Precio: menor a mayor';
  String? _categoriaSeleccionada;
  String? _marcaSeleccionada;
  String? _statusSeleccionado;  // available | out_of_stock | null
  final Map<String, bool> _preciosSeleccionados = {
    'Menos de \$1,000':    false,
    '\$1,000 - \$5,000':   false,
    'Más de \$5,000':      false,
  };

  @override
  void initState() {
    super.initState();
    _productService = ProductService(ApiService());
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _productService.getProducts();
      setState(() {
        _allProducts = data;
        _applyFilters();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    List<Product> result = List.from(_allProducts);

    // Categoría
    if (_categoriaSeleccionada != null) {
      result = result.where((p) => p.category == _categoriaSeleccionada).toList();
    }

    // Marca
    if (_marcaSeleccionada != null) {
      result = result.where((p) =>
          p.brand.toLowerCase() == _marcaSeleccionada!.toLowerCase()).toList();
    }

    // Status
    if (_statusSeleccionado != null) {
      result = result.where((p) => p.status == _statusSeleccionado).toList();
    }

    // Precios
    final activePrices = _preciosSeleccionados.entries
        .where((e) => e.value).map((e) => e.key).toList();
    if (activePrices.isNotEmpty) {
      result = result.where((p) {
        for (final rango in activePrices) {
          if (rango == 'Menos de \$1,000'  && p.price < 1000)  return true;
          if (rango == '\$1,000 - \$5,000' && p.price >= 1000 && p.price <= 5000) return true;
          if (rango == 'Más de \$5,000'    && p.price > 5000)  return true;
        }
        return false;
      }).toList();
    }

    // Ordenar
    result.sort((a, b) {
      switch (_ordenarPor) {
        case 'Precio: menor a mayor': return a.price.compareTo(b.price);
        case 'Precio: mayor a menor': return b.price.compareTo(a.price);
        case 'Nombre A-Z':            return a.name.compareTo(b.name);
        case 'Nombre Z-A':            return b.name.compareTo(a.name);
        default:                      return 0;
      }
    });

    _filtered = result;
  }

  // Categorías y marcas dinámicas desde los datos
  List<String> get _categories => _allProducts
      .map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
  List<String> get _brands => _allProducts
      .map((p) => p.brand).where((b) => b.isNotEmpty).toSet().toList()..sort();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildFiltros(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Filtros', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          // Botón refrescar
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _fetchProducts,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _fetchProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Hero banner
              SizedBox(
                height: 260,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/fondo_productos.jpg', fit: BoxFit.cover),
                    Container(color: Colors.black.withOpacity(0.5)),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Explora Nuestro Catálogo',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _loading
                                  ? 'Cargando productos...'
                                  : '${_filtered.length} producto${_filtered.length != 1 ? "s" : ""} disponibles',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar los productos',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _fetchProducts,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            const Text('Sin resultados', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Prueba cambiando los filtros', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _resetFiltros,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('Limpiar filtros', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: _filtered.length,
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 10,
        childAspectRatio: 0.60,
      ),
      itemBuilder: (context, i) {
        final p = _filtered[i];
        return ProductCard(
          product: p,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
          ),
        );
      },
    );
  }

  // ── Drawer de filtros ──────────────────────────────
  Widget _buildFiltros() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () { _resetFiltros(); Navigator.pop(context); },
                    child: const Text('Limpiar', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ordenar
              _sectionTitle('Ordenar por'),
              const SizedBox(height: 8),
              _dropdownOrden(),
              const SizedBox(height: 20),

              // Disponibilidad
              _sectionTitle('Disponibilidad'),
              _radioItem('Disponibles', _statusSeleccionado, 'available',
                  (v) => setState(() { _statusSeleccionado = v; _applyFilters(); })),
              _radioItem('Sin stock', _statusSeleccionado, 'out_of_stock',
                  (v) => setState(() { _statusSeleccionado = v; _applyFilters(); })),
              _radioItem('Todos', _statusSeleccionado, null,
                  (v) => setState(() { _statusSeleccionado = null; _applyFilters(); })),
              const SizedBox(height: 20),

              // Categorías dinámicas
              if (_categories.isNotEmpty) ...[
                _sectionTitle('Categoría'),
                ..._categories.map((cat) =>
                    _radioItem(cat, _categoriaSeleccionada, cat,
                        (v) => setState(() { _categoriaSeleccionada = v; _applyFilters(); }))),
                _radioItem('Todas', _categoriaSeleccionada, null,
                    (v) => setState(() { _categoriaSeleccionada = null; _applyFilters(); })),
                const SizedBox(height: 20),
              ],

              // Marcas dinámicas
              if (_brands.isNotEmpty) ...[
                _sectionTitle('Marca'),
                ..._brands.map((marca) =>
                    _radioItem(marca, _marcaSeleccionada, marca,
                        (v) => setState(() { _marcaSeleccionada = v; _applyFilters(); }))),
                _radioItem('Todas', _marcaSeleccionada, null,
                    (v) => setState(() { _marcaSeleccionada = null; _applyFilters(); })),
                const SizedBox(height: 20),
              ],

              // Rangos de precio
              _sectionTitle('Rango de precio'),
              ..._preciosSeleccionados.keys.map(
                (key) => CheckboxListTile(
                  value: _preciosSeleccionados[key],
                  activeColor: AppColors.primary,
                  checkColor: AppColors.textPrimary,
                  title: Text(key, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  onChanged: (v) => setState(() {
                    _preciosSeleccionados[key] = v!;
                    _applyFilters();
                  }),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetFiltros() {
    setState(() {
      _ordenarPor             = 'Precio: menor a mayor';
      _categoriaSeleccionada  = null;
      _marcaSeleccionada      = null;
      _statusSeleccionado     = null;
      _preciosSeleccionados.updateAll((_, __) => false);
      _applyFilters();
    });
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
  );

  Widget _dropdownOrden() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: _ordenarPor,
        dropdownColor: AppColors.surface,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(color: AppColors.textPrimary),
        items: ['Precio: menor a mayor', 'Precio: mayor a menor', 'Nombre A-Z', 'Nombre Z-A']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() { _ordenarPor = v!; _applyFilters(); }),
      ),
    );
  }

  Widget _radioItem(String title, String? groupValue, String? value, Function(String?) onChanged) {
    return RadioListTile<String?>(
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      dense: true,
      title: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      onChanged: onChanged,
    );
  }
}