import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          "Notificaciones",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SectionTitle(title: "Hoy"),
          SizedBox(height: 16),
          _NotificationCard(
            icon: Icons.shopping_bag_rounded,
            title: "Compra confirmada",
            subtitle: "Tu pedido fue procesado correctamente.",
            time: "Hace 5 min",
          ),
          SizedBox(height: 14),
          _NotificationCard(
            icon: Icons.build_circle_rounded,
            title: "Equipo reparado",
            subtitle: "Tu laptop ya está lista para recoger.",
            time: "Hace 20 min",
          ),
          SizedBox(height: 28),
          _SectionTitle(title: "Ayer"),
          SizedBox(height: 16),
          _NotificationCard(
            icon: Icons.local_offer_rounded,
            title: "Nueva promoción",
            subtitle: "Descuentos en componentes gaming.",
            time: "Ayer",
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}