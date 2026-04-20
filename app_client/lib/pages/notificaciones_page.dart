import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B0F1A),
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text("Notificaciones",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0B0F1A),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: ListView.separated(
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _notificationCard(),
          ),
        ),
      ),
    );
  }

  static Widget _notificationCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF111827)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications, color: AppColors.primary, size: 24),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Título de la notificación",
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text("Descripción breve de la notificación.",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text("Hace 1 min",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
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