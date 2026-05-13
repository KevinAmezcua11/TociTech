import 'package:flutter/material.dart';

import '../../../database/local/notification_local_service.dart';
import '../../../services/api_service.dart';
import '../../../services/order_notification_sync_service.dart';
import '../../../services/order_service.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/app_snackbar.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final OrderService _orderService = OrderService(ApiService());

  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final orders = await _orderService.getOrders();
      await OrderNotificationSyncService.syncPurchaseNotifications(orders);
    } catch (_) {
      _error =
          'No pudimos actualizar tus notificaciones. Mostrando eventos guardados.';
    }

    final localNotifications =
        await NotificationLocalService.getNotifications();

    if (!mounted) return;

    setState(() {
      _notifications = localNotifications;
      _loading = false;
    });
  }

  Future<void> _markAllRead() async {
    await NotificationLocalService.markAllNotificationsRead();
    await _loadNotifications();
    if (mounted) {
      AppSnackbar.success(context, 'Notificaciones marcadas como leídas.');
    }
  }

  Future<void> _markRead(String id) async {
    await NotificationLocalService.markNotificationRead(id);
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: [
          if (_notifications.any((item) => item['leida'] == 0))
            IconButton(
              tooltip: 'Marcar como leídas',
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded),
              color: AppColors.primary,
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          if (_error != null) _noticeCard(_error!),
          SizedBox(height: _error == null ? 120 : 40),
          const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textMuted,
            size: 56,
          ),
          SizedBox(height: 14),
          Text(
            'Sin notificaciones',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aquí aparecerán eventos reales de tus compras aprobadas o canceladas.',
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
      itemCount: _notifications.length + (_error == null ? 0 : 1),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (_error != null && index == 0) {
          return _noticeCard(_error!);
        }

        final notificationIndex = _error == null ? index : index - 1;
        final notification = _notifications[notificationIndex];

        return _NotificationCard(
          notification: notification,
          onTap: () => _markRead(notification['id'] as String),
        );
      },
    );
  }

  Widget _noticeCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final type = notification['type'] as String? ?? 'general';
    final unread = notification['leida'] == 0;
    final color = switch (type) {
      'purchase_approved' => AppColors.green,
      'purchase_cancelled' => Colors.redAccent,
      _ => AppColors.primary,
    };
    final icon = switch (type) {
      'purchase_approved' => Icons.check_circle_outline_rounded,
      'purchase_cancelled' => Icons.cancel_outlined,
      _ => Icons.notifications_none_rounded,
    };

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unread
                  ? color.withValues(alpha: 0.28)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String? ?? 'Notificación',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification['message'] as String? ??
                          'Tienes una actualización.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _formatDate(notification['created_at'] as String?),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';

    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
