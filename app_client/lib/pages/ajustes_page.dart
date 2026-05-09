import 'package:flutter/material.dart';
import 'package:tocitech/pages/mis_pedidos_page.dart';

import '../services/settings_preferences.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  bool _saving = false;

  bool get _isLight => settingsController.value.themeMode == ClientThemeMode.light;
  Color get _background => _isLight ? const Color(0xFFF7F8FC) : AppColors.background;
  Color get _surface => _isLight ? const Color(0xFFFFFFFF) : AppColors.surface;
  Color get _controlSurface => _isLight ? const Color(0xFFF0F3FA) : AppColors.background;
  Color get _textPrimary => _isLight ? const Color(0xFF171923) : AppColors.textPrimary;
  Color get _textSecondary =>
      _isLight ? const Color(0xB8171923) : AppColors.textSecondary;
  Color get _borderColor =>
      _isLight ? const Color(0xFFE4E8F2) : Colors.white.withOpacity(0.07);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ClientSettings>(
      valueListenable: settingsController,
      builder: (context, settings, _) {
        final isLight = settings.themeMode == ClientThemeMode.light;

        return Scaffold(
          backgroundColor: _background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Ajustes',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _profileSection(),
                const SizedBox(height: 22),
                _settingsCard(
                  icon: Icons.palette_outlined,
                  title: 'Tema',
                  description: 'Cambia la apariencia principal de la app.',
                  child: Row(
                    children: [
                      Expanded(
                        child: _themeButton(
                          label: 'Oscuro',
                          icon: Icons.dark_mode_outlined,
                          selected: !isLight,
                          onTap: () => _updateTheme(ClientThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _themeButton(
                          label: 'Claro',
                          icon: Icons.light_mode_outlined,
                          selected: isLight,
                          onTap: () => _updateTheme(ClientThemeMode.light),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _settingsCard(
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  description: 'Activa o desactiva avisos de la app.',
                  child: SwitchListTile(
                    value: settings.notificationsEnabled,
                    onChanged: _updateNotifications,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Recibir notificaciones',
                      style: TextStyle(color: _textPrimary),
                    ),
                    subtitle: Text(
                      settings.notificationsEnabled
                          ? 'Los avisos estan activos.'
                          : 'Los avisos estan desactivados.',
                      style: TextStyle(color: _textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _settingsCard(
                  icon: Icons.info_outline_rounded,
                  title: 'Informacion de la aplicacion',
                  description: 'Datos generales de TociTech.',
                  child: Column(
                    children: [
                      _infoRow('Aplicacion', 'TociTech'),
                      _infoRow('Version', '1.0.0+1'),
                      _infoRow('Creditos', 'TociTech'),
                      _infoRow('Tema actual', isLight ? 'Claro' : 'Oscuro'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _logoutButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profileSection() {
    return _settingsCard(
      icon: Icons.person_outline_rounded,
      title: 'Perfil y seguridad',
      description: 'Accesos rapidos de tu cuenta.',
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primary.withOpacity(0.16),
                child: Icon(Icons.person, color: AppColors.primary, size: 42),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Juanito03',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reparaciones: 3  Compras: 5',
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MisPedidosPage()),
                );
              },
              icon: Icon(Icons.more_horiz, color: _textPrimary),
              label: Text('Mas detalles', style: TextStyle(color: _textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard({
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
        boxShadow: _isLight
            ? [
                BoxShadow(
                  color: const Color(0xFF1E293B).withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isLight
                      ? AppColors.primary.withOpacity(0.10)
                      : AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(color: _textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _themeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : _controlSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : _borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : _textSecondary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: _textSecondary))),
          Text(
            value,
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _confirmarCierreSesion(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
        label: const Text(
          'Cerrar sesion',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _updateTheme(ClientThemeMode themeMode) async {
    await _saveSetting(() => settingsController.setTheme(themeMode), 'Tema aplicado.');
  }

  Future<void> _updateNotifications(bool enabled) async {
    await _saveSetting(
      () => settingsController.setNotificationsEnabled(enabled),
      enabled ? 'Notificaciones activadas.' : 'Notificaciones desactivadas.',
    );
  }

  Future<void> _saveSetting(Future<void> Function() action, String message) async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await action();
      if (mounted) _showMessage(message);
    } catch (_) {
      if (mounted) {
        _showMessage(
          'No se pudo guardar el ajuste. Revisa el almacenamiento del dispositivo.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.green,
      ),
    );
  }

  void _confirmarCierreSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cerrar sesion?',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: _textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
  }
}
