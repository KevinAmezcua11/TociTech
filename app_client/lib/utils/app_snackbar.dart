import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppSnackBarType { success, error, info }

class AppSnackBar {
  const AppSnackBar._();

  static void success(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.info);
  }

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final color = switch (type) {
      AppSnackBarType.success => AppColors.green,
      AppSnackBarType.error => Colors.redAccent,
      AppSnackBarType.info => AppColors.blue,
    };

    final icon = switch (type) {
      AppSnackBarType.success => Icons.check_circle_outline_rounded,
      AppSnackBarType.error => Icons.error_outline_rounded,
      AppSnackBarType.info => Icons.info_outline_rounded,
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
