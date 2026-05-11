import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/product_model.dart';
import '../../../database/local/cart_local_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_snackbar.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final PageController _pageController;
  int _imagenActiva = 0;

  Product get p => widget.product;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hayStock = p.isAvailable;
    final double porcentajeStock = p.stock > 0 && p.minStock > 0
        ? (p.stock / (p.stock + p.minStock)).clamp(0.0, 1.0)
        : p.stock > 0 ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: hayStock
                ? () async {
                    await CartLocalService.addToCart(p);
                    if (context.mounted) {
                      AppSnackbar.success(context, '${p.name} agregado al carrito');
                    }
                  }
                : null,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text(
              'Agregar al carrito',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.surface,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen(es)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen principal
                  _buildMainImage(),

                  // Gradiente inferior
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.background, Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // Miniaturas si hay varias imágenes
                  if (p.images.length > 1)
                    Positioned(
                      bottom: 12, left: 0, right: 0,
                      child: _buildImageThumbs(),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Nombre
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  // Marca · Modelo
                  if (p.brand.isNotEmpty || p.model.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [p.brand, p.model].where((s) => s.isNotEmpty).join(' · '),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],

                  // SKU
                  if (p.sku.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('SKU: ${p.sku}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],

                  const SizedBox(height: 10),

                  // Descripción
                  if (p.description.isNotEmpty)
                    Text(p.description,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),

                  const SizedBox(height: 16),

                  // Precio
                  Text(
                    '\$${p.price.toStringAsFixed(0)} MXN',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Categoría badge
                  if (p.category.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _badge(p.category, AppColors.primary),
                  ],

                  const SizedBox(height: 24),

                  // Stock
                  _seccionTitulo('Disponibilidad'),
                  const SizedBox(height: 10),
                  _stockIndicador(porcentajeStock, hayStock),

                  // Garantía
                  if (p.warranty.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _infoRow(Icons.verified_outlined, 'Garantía', p.warranty),
                  ],

                  // Especificaciones
                  if (p.specs.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _seccionTitulo('Especificaciones'),
                    const SizedBox(height: 10),
                    _specsTable(),
                  ],

                  const SizedBox(height: 24),

                  // Estado del producto
                  _statusInfo(hayStock),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Imagen principal ──────────────────────────────
  Widget _buildMainImage() {
    if (p.images.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Center(
          child: Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 64),
        ),
      );
    }

    Widget imageWidget(int index) => AppNetworkImage(
      url: p.images[index],
      fit: BoxFit.contain,
      loading: Container(
        color: AppColors.surface,
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: Container(
        color: AppColors.surface,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 64),
        ),
      ),
    );

    if (p.images.length == 1) return imageWidget(0);

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _imagenActiva = i),
          itemCount: p.images.length,
          itemBuilder: (_, i) => imageWidget(i),
        ),
        // Flecha izquierda
        if (_imagenActiva > 0)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(child: _arrowButton(Icons.chevron_left_rounded, -1)),
          ),
        // Flecha derecha
        if (_imagenActiva < p.images.length - 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(child: _arrowButton(Icons.chevron_right_rounded, 1)),
          ),
        // Contador de imagen
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_imagenActiva + 1} / ${p.images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _arrowButton(IconData icon, int direction) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          _imagenActiva + direction,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.40),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildImageThumbs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(p.images.length, (i) {
        final active = i == _imagenActiva;
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  // ── Stock indicador ───────────────────────────────
  Widget _stockIndicador(double porcentaje, bool hayStock) {
    final Color color = porcentaje > 0.5
        ? AppColors.green
        : porcentaje > 0.2
        ? const Color(0xFFFFA726)
        : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hayStock ? '${p.stock} piezas disponibles' : 'Sin stock',
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: porcentaje,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabla de especificaciones ─────────────────────
  Widget _specsTable() {
    final entries = p.specs.entries.toList();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          final isLast = i == entries.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: isLast ? null : Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                      e.key.isEmpty ? '' : '${e.key[0].toUpperCase()}${e.key.substring(1)}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(e.value.toString(),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Info de estado ────────────────────────────────
  Widget _statusInfo(bool hayStock) {
    if (hayStock) return const SizedBox.shrink();

    final isDiscontinued = p.status == 'discontinued';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDiscontinued
                  ? 'Este producto ha sido descontinuado'
                  : 'Este producto no tiene stock disponible actualmente',
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────
  Widget _seccionTitulo(String texto) => Text(
    texto,
    style: const TextStyle(
        color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
  );

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}