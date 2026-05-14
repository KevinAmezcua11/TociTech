import 'package:flutter/material.dart';

import '../../../database/local/notification_local_service.dart';
import '../../../theme/app_theme.dart';
import 'notificaciones_page.dart' show NotificationCard;

class HistorialNotificacionesPage extends StatefulWidget {
  const HistorialNotificacionesPage({super.key, required this.userId});

  final String userId;

  @override
  State<HistorialNotificacionesPage> createState() =>
      _HistorialNotificacionesPageState();
}

class _HistorialNotificacionesPageState
    extends State<HistorialNotificacionesPage> {
  List<Map<String, dynamic>> _read = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final data = await NotificationLocalService.getReadNotifications(widget.userId);
    if (!mounted) return;
    setState(() {
      _read = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Historial',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_read.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.history_rounded, color: AppColors.textMuted, size: 56),
          SizedBox(height: 14),
          Text(
            'Sin historial',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aquí aparecerán las notificaciones que ya leíste.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: _read.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => NotificationCard(
        notification: _read[index],
        onTap: () {},
      ),
    );
  }
}
