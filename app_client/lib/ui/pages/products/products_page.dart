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

  List<Product> _allProducts = [];
  List<Product> _filtered    = [];
  bool _loading  = true;
  String? _error;

  // ── Filtros ──────────────────────────────────────
  String  _ordenarPor           = 'Precio: menor a mayor';
  String? _categoriaSeleccionada;
  String? _marcaSeleccionada;
  String? _modeloSeleccionado;
  final Map<String, bool> _preciosSeleccionados = {
    'Menos de \$500':          false,
    '\$500 - \$1,500':         false,
    '\$1,500 - \$5,000':       false,
    '\$5,000 - \$15,000':      false,
    '\$15,000 - \$30,000':     false,
    'Más de \$30,000':         false,
  };

  // Especificaciones importantes a filtrar (clave Firestore → label visible)
  static const Map<String, String> _specKeys = {
    'RAM':         'RAM',
    'Procesador':  'Procesador',
    'Almacenamiento': 'Almacenamiento',
    'GPU':         'GPU / Tarjeta gráfica',
    'Pantalla':    'Pantalla',
    'Conectividad':'Conectividad',
    'Sistema operativo': 'Sistema operativo',
    'Velocidad':   'Velocidad',
    'Capacidad':   'Capacidad',
    'Frecuencia':  'Frecuencia',
    'Formato':     'Formato',
    'Potencia':    'Potencia',
    'Núcleos':     'Núcleos',
  };

  // spec key seleccionada → valor seleccionado
  final Map<String, String?> _specFilters = {};

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
      // Solo mostrar disponibles
      final disponibles = data.where((p) => p.status == 'available' && p.stock > 0).toList();
      setState(() {
        _allProducts = disponibles;
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

    if (_categoriaSeleccionada != null) {
      result = result.where((p) => p.category == _categoriaSeleccionada).toList();
    }

    if (_marcaSeleccionada != null) {
      result = result.where((p) =>
          p.brand.toLowerCase() == _marcaSeleccionada!.toLowerCase()).toList();
    }

    if (_modeloSeleccionado != null) {
      result = result.where((p) =>
          p.model.toLowerCase() == _modeloSeleccionado!.toLowerCase()).toList();
    }

    // Filtros de specs
    _specFilters.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        result = result.where((p) {
          final specVal = p.specs[key]?.toString().toLowerCase() ?? '';
          return specVal.contains(value.toLowerCase());
        }).toList();
      }
    });

    // Rangos de precio
    final activeRanges = _preciosSeleccionados.entries
        .where((e) => e.value).map((e) => e.key).toList();
    if (activeRanges.isNotEmpty) {
      result = result.where((p) {
        for (final r in activeRanges) {
          if (r == 'Menos de \$500'       && p.price < 500)                          return true;
          if (r == '\$500 - \$1,500'      && p.price >= 500   && p.price < 1500)     return true;
          if (r == '\$1,500 - \$5,000'    && p.price >= 1500  && p.price < 5000)     return true;
          if (r == '\$5,000 - \$15,000'   && p.price >= 5000  && p.price < 15000)    return true;
          if (r == '\$15,000 - \$30,000'  && p.price >= 15000 && p.price < 30000)    return true;
          if (r == 'Más de \$30,000'      && p.price >= 30000)                       return true;
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

  // ── Datos dinámicos del backend ───────────────────
  List<String> get _categories => _allProducts
      .map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()..sort();

  List<String> get _brands => _allProducts
      .map((p) => p.brand).where((b) => b.isNotEmpty).toSet().toList()..sort();

  List<String> get _models {
    var list = _allProducts.map((p) => p.model).where((m) => m.isNotEmpty);
    if (_marcaSeleccionada != null) {
      list = _allProducts
          .where((p) => p.brand.toLowerCase() == _marcaSeleccionada!.toLowerCase())
          .map((p) => p.model)
          .where((m) => m.isNotEmpty);
    }
    return list.toSet().toList()..sort();
  }

  // Obtiene los valores únicos de una spec key presentes en los productos actuales
  List<String> _specValues(String key) {
    return _allProducts
        .map((p) => p.specs[key]?.toString() ?? '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()..sort();
  }

  // Specs que tienen al menos un valor en los productos
  List<String> get _activeSpecKeys => _specKeys.keys
      .where((k) => _specValues(k).isNotEmpty)
      .toList();

  bool get _hasFilters =>
      _categoriaSeleccionada != null ||
      _marcaSeleccionada != null ||
      _modeloSeleccionado != null ||
      _preciosSeleccionados.values.any((v) => v) ||
      _specFilters.values.any((v) => v != null);

  void _resetFiltros() {
    setState(() {
      _categoriaSeleccionada = null;
      _marcaSeleccionada     = null;
      _modeloSeleccionado    = null;
      _ordenarPor            = 'Precio: menor a mayor';
      _preciosSeleccionados.updateAll((_, __) => false);
      _specFilters.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Filtros', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          if (_hasFilters)
            TextButton(
              onPressed: _resetFiltros,
              child: const Text('Limpiar', style: TextStyle(color: AppColors.primary)),
            ),
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
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/fondo_productos.jpg', fit: BoxFit.cover),
                    Container(color: Colors.black.withOpacity(0.5)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
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

              Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            const Text('No se pudieron cargar los productos',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(_error!,
                textAlign: TextAlign.center,
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
            const Text('Sin resultados',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Prueba cambiando los filtros',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _resetFiltros,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
              child: const Text('Limpiar filtros', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: _filtered.length,
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
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

  // ── Drawer de filtros ─────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Encabezado fijo
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () { _resetFiltros(); Navigator.pop(context); },
                    child: const Text('Limpiar todo',
                        style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 16),

            // Contenido scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [

                  // Ordenar
                  _sectionTitle('Ordenar por'),
                  const SizedBox(height: 6),
                  _dropdownOrden(),
                  const SizedBox(height: 20),

                  // Categoría
                  if (_categories.isNotEmpty) ...[
                    _sectionTitle('Categoría'),
                    ..._categories.map((cat) => _radioTile(
                          cat, _categoriaSeleccionada, cat,
                          (v) => setState(() {
                            _categoriaSeleccionada = v;
                            _marcaSeleccionada = null;
                            _modeloSeleccionado = null;
                            _applyFilters();
                          }),
                        )),
                    _radioTile('Todas', _categoriaSeleccionada, null,
                        (v) => setState(() {
                              _categoriaSeleccionada = null;
                              _applyFilters();
                            })),
                    const SizedBox(height: 20),
                  ],

                  // Marca
                  if (_brands.isNotEmpty) ...[
                    _sectionTitle('Marca'),
                    ..._brands.map((m) => _radioTile(
                          m, _marcaSeleccionada, m,
                          (v) => setState(() {
                            _marcaSeleccionada = v;
                            _modeloSeleccionado = null;
                            _applyFilters();
                          }),
                        )),
                    _radioTile('Todas', _marcaSeleccionada, null,
                        (v) => setState(() {
                              _marcaSeleccionada = null;
                              _modeloSeleccionado = null;
                              _applyFilters();
                            })),
                    const SizedBox(height: 20),
                  ],

                  // Modelo (depende de marca)
                  if (_models.isNotEmpty) ...[
                    _sectionTitle('Modelo'),
                    ..._models.map((m) => _radioTile(
                          m, _modeloSeleccionado, m,
                          (v) => setState(() {
                            _modeloSeleccionado = v;
                            _applyFilters();
                          }),
                        )),
                    _radioTile('Todos', _modeloSeleccionado, null,
                        (v) => setState(() {
                              _modeloSeleccionado = null;
                              _applyFilters();
                            })),
                    const SizedBox(height: 20),
                  ],

                  // Especificaciones dinámicas
                  if (_activeSpecKeys.isNotEmpty) ...[
                    _sectionTitle('Especificaciones'),
                    const SizedBox(height: 8),
                    ..._activeSpecKeys.map((key) {
                      final values = _specValues(key);
                      final label  = _specKeys[key] ?? key;
                      final current = _specFilters[key];
                      return _specSection(key, label, values, current);
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Rango de precio
                  _sectionTitle('Rango de precio'),
                  ..._preciosSeleccionados.keys.map((key) => CheckboxListTile(
                        value: _preciosSeleccionados[key],
                        activeColor: AppColors.primary,
                        checkColor: AppColors.textPrimary,
                        dense: true,
                        title: Text(key,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        onChanged: (v) => setState(() {
                          _preciosSeleccionados[key] = v!;
                          _applyFilters();
                        }),
                      )),
                  const SizedBox(height: 16),

                  // Botón aplicar
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
          ],
        ),
      ),
    );
  }

  // ── Sección de spec con chips de valores ──────────
  Widget _specSection(
      String key, String label, List<String> values, String? current) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Chip "Todos"
              _specChip('Todos', current == null, () => setState(() {
                    _specFilters[key] = null;
                    _applyFilters();
                  })),
              ...values.map((v) => _specChip(v, current == v, () => setState(() {
                    _specFilters[key] = v;
                    _applyFilters();
                  }))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Helpers UI ────────────────────────────────────
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      );

  Widget _dropdownOrden() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: DropdownButton<String>(
          value: _ordenarPor,
          dropdownColor: AppColors.surface,
          isExpanded: true,
          underline: const SizedBox(),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          items: [
            'Precio: menor a mayor',
            'Precio: mayor a menor',
            'Nombre A-Z',
            'Nombre Z-A',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() { _ordenarPor = v!; _applyFilters(); }),
        ),
      );

  Widget _radioTile(String title, String? groupValue, String? value,
      Function(String?) onChanged) {
    return RadioListTile<String?>(
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      onChanged: onChanged,
    );
  }
}