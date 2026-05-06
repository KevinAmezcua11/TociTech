import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hayStock = product.isAvailable;
    final bool stockBajo = product.isLowStock;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: product.firstImage.isNotEmpty
                    ? Image.network(
                        product.firstImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : _imagePlaceholder(loading: true),
                      )
                    : _imagePlaceholder(),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Marca · Modelo
                    if (product.brand.isNotEmpty || product.model.isNotEmpty)
                      Text(
                        [product.brand, product.model].where((s) => s.isNotEmpty).join(' · '),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Precio
                    Text(
                      '\$${product.price.toStringAsFixed(0)} MXN',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Badge de disponibilidad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.stock} pzs',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        _stockBadge(hayStock, stockBajo),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    return Container(
      color: const Color(0xFF1E1E2A),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            : const Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 32),
      ),
    );
  }

  Widget _stockBadge(bool hayStock, bool stockBajo) {
    if (!hayStock) {
      return _badge('Sin stock', Colors.redAccent);
    }
    if (stockBajo) {
      return _badge('Stock bajo', const Color(0xFFFFA726));
    }
    return _badge('Disponible', AppColors.green);
  }

  Widget _badge(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}