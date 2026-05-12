import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BusquedaPage extends StatelessWidget {
  const BusquedaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          "Buscador",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Encuentra lo que necesitas",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Productos, componentes y servicios tecnológicos.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  "Buscar productos...",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Icon(Icons.tune_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _ChipWidget(label: "Gaming"),
              _ChipWidget(label: "Laptops"),
              _ChipWidget(label: "Mouse"),
              _ChipWidget(label: "Teclados"),
              _ChipWidget(label: "Redes"),
              _ChipWidget(label: "Reparación"),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            "Tendencias",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _ProductCard(
                  title: "RTX 3050 ASUS",
                  image: "assets/asusdual.png",
                ),
                SizedBox(width: 18),
                _ProductCard(
                  title: "AMD Radeon PRO",
                  image: "assets/amdradeon.png",
                ),
                SizedBox(width: 18),
                _ProductCard(
                  title: "Mouse Gamer",
                  image: "assets/mouseacteck.png",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipWidget extends StatelessWidget {
  final String label;

  const _ChipWidget({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String image;

  const _ProductCard({
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Popular",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(image),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Disponible ahora",
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}