import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Helper centralizado para mostrar Snackbars con mensajes amigables.
/// Nunca expone errores técnicos al usuario.
class AppSnackbar {
  // ─── Éxito ───────────────────────────────────────────────────────────────
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.green,
    );
  }

  // ─── Error (amigable) ────────────────────────────────────────────────────
  static void error(BuildContext context, String message) {
    _show(
      context,
      message: _friendly(message),
      icon: Icons.error_outline_rounded,
      color: Colors.redAccent,
    );
  }

  // ─── Info ────────────────────────────────────────────────────────────────
  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      color: AppColors.blue,
    );
  }

  // ─── Sesión expirada ─────────────────────────────────────────────────────
  static void sessionExpired(BuildContext context) {
    _show(
      context,
      message: 'Tu sesión expiró. Por favor inicia sesión nuevamente.',
      icon: Icons.lock_clock_outlined,
      color: Colors.orange,
      duration: const Duration(seconds: 4),
    );
  }

  // ─── Sin conexión ────────────────────────────────────────────────────────
  static void noConnection(BuildContext context) {
    _show(
      context,
      message: 'Sin conexión a internet. Verifica tu red e intenta de nuevo.',
      icon: Icons.wifi_off_rounded,
      color: Colors.orange,
    );
  }

  // ─── Privado: construye y muestra ────────────────────────────────────────
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: duration,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.surface,
          content: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ─── Convierte mensajes técnicos a texto amigable ─────────────────────────
  static String _friendly(String raw) {
    final msg = raw
        .replaceAll('Exception: ', '')
        .replaceAll('exception: ', '')
        .trim()
        .toLowerCase();

    // Token / sesión
    if (msg.contains('token') || msg.contains('unauthorized') || msg.contains('401')) {
      return 'Tu sesión expiró. Por favor inicia sesión nuevamente.';
    }

    // Sin conexión
    if (msg.contains('sin conexión') || msg.contains('socketexception') || msg.contains('network')) {
      return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
    }

    // Tiempo de espera
    if (msg.contains('tiempo de espera') || msg.contains('timeout') || msg.contains('timeoutexception')) {
      return 'El servidor tardó demasiado en responder. Intenta de nuevo.';
    }

    // Credenciales inválidas
    if (msg.contains('invalid credentials') || msg.contains('credenciales')) {
      return 'Usuario o contraseña incorrectos.';
    }

    // Usuario ya existe
    if (msg.contains('already exists') || msg.contains('username')) {
      return 'Este nombre de usuario ya está registrado. Elige otro.';
    }

    // Stock
    if (msg.contains('stock') || msg.contains('disponible')) {
      return 'No hay suficiente stock disponible.';
    }

    // Servidor
    if (msg.contains('server error') || msg.contains('500') || msg.contains('internal')) {
      return 'Ocurrió un problema en el servidor. Intenta más tarde.';
    }

    // Error genérico de GET/POST/PUT/DELETE — oculta detalles internos
    if (msg.startsWith('error get:') ||
        msg.startsWith('error post:') ||
        msg.startsWith('error put:') ||
        msg.startsWith('error delete:')) {
      return 'No se pudo completar la operación. Revisa tu conexión e intenta de nuevo.';
    }

    // Si el mensaje ya es legible (no contiene paths, objetos, etc.) lo devuelve tal cual.
    // De lo contrario muestra el genérico.
    final looksClean = msg.length < 120 &&
        !msg.contains('(') &&
        !msg.contains('{') &&
        !msg.contains('http') &&
        !msg.contains('dart:');

    return looksClean
        ? raw.replaceAll('Exception: ', '').trim()
        : 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
