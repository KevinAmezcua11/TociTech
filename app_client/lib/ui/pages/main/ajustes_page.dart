import 'package:flutter/material.dart';

import '../../../database/local/session_local_service.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../services/order_notification_sync_service.dart';
import '../../../services/order_service.dart';
import '../../../services/user_profile_service.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/app_snackbar.dart';
import '../auth/login_page.dart';
import 'mis_pedidos_page.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  late final UserProfileService _profileService;
  late final OrderService _orderService;

  User? _user;
  List<Order> _orders = [];
  bool _loading = true;

  String? _error;

  int get _comprasRealizadas =>
      _orders.where((order) => order.type == 'product').length;

  int get _reparacionesSolicitadas =>
      _orders.where((order) => order.type == 'service').length;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _profileService = UserProfileService(api);
    _orderService = OrderService(api);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        _profileService.getMe(),
        _orderService.getOrders(),
      ]);

      if (!mounted) return;

      setState(() {
        _user = results[0] as User;
        _orders = results[1] as List<Order>;
      });
      await OrderNotificationSyncService.syncPurchaseNotifications(_orders);
    } catch (e) {
      await _loadLocalSessionFallback();
      if (!mounted) return;
      setState(() {
        _error =
            'No pudimos actualizar el perfil. Mostrando datos guardados en este dispositivo.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadLocalSessionFallback() async {
    final session = await SessionLocalService.getSession();
    if (session == null || !mounted) return;

    setState(() {
      _user = User(
        id: session['user_id'] as String? ?? '',
        username: session['username'] as String? ?? '',
        names: session['names'] as String? ?? '',
        lastnames: session['lastnames'] as String? ?? '',
        email: session['email'] as String? ?? '',
        phone: session['phone'] as String? ?? '',
        role: session['role'] as String? ?? 'client',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _loadProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 120),
          children: [
            if (_error != null) ...[
              _noticeCard(_error!),
              const SizedBox(height: 16),
            ],
            _profileHeader(user),
            const SizedBox(height: 18),
            _activityStats(),
            const SizedBox(height: 24),
            _sectionTitle('Cuenta'),
            const SizedBox(height: 12),
            _settingsCard([
              _settingsTile(
                icon: Icons.edit_outlined,
                title: 'Editar perfil',
                subtitle: 'Nombre, correo, telefono y usuario',
                onTap: user == null ? null : () => _showEditProfileSheet(user),
              ),
              _settingsTile(
                icon: Icons.receipt_long_outlined,
                title: 'Mis pedidos',
                subtitle: 'Compras y servicios solicitados',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MisPedidosPage()),
                ),
              ),
            ]),
            const SizedBox(height: 28),
            _logoutButton(),
          ],
        ),
      ),
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
          IconButton(
            tooltip: 'Reintentar',
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(User? user) {
    final fullName = user == null
        ? 'Cargando perfil...'
        : '${user.names} ${user.lastnames}'.trim();
    final initials = user == null
        ? ''
        : [
            if (user.names.trim().isNotEmpty) user.names.trim()[0],
            if (user.lastnames.trim().isNotEmpty) user.lastnames.trim()[0],
          ].join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary.withValues(alpha: 0.16),
            child: _loading && user == null
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Sin nombre registrado' : fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user == null ? 'Sin correo' : user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _profileChip('@${user?.username ?? 'usuario'}'),
                    _profileChip(user?.phone ?? 'Sin telefono'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    );
  }

  Widget _activityStats() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            icon: Icons.shopping_bag_outlined,
            color: AppColors.primary,
            value: _loading ? '...' : '$_comprasRealizadas',
            label: 'Compras',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            icon: Icons.handyman_outlined,
            color: AppColors.blue,
            value: _loading ? '...' : '$_reparacionesSolicitadas',
            label: 'Reparaciones',
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _confirmarCierreSesion,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text(
          'Cerrar sesion',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileSheet(User user) async {
    final result = await showModalBottomSheet<User?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditProfileSheet(user: user),
    );

    if (result == null || !mounted) return;

    try {
      final updated = await _profileService.updateMe(
        username: result.username,
        names: result.names,
        lastnames: result.lastnames,
        email: result.email,
        phone: result.phone,
      );
      if (!mounted) return;
      setState(() => _user = updated);
      AppSnackbar.success(context, 'Perfil actualizado correctamente.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.toString());
    }
  }


  void _confirmarCierreSesion() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Salir de tu\ncuenta?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: () async {
                  await SessionLocalService.clearSession();
                  ApiService().token = null;

                  if (!mounted || !context.mounted || !dialogContext.mounted) {
                    return;
                  }

                  Navigator.pop(dialogContext);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Salir',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Edit-profile sheet ────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});

  final User user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _namesCtrl;
  late final TextEditingController _lastnamesCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _usernameCtrl  = TextEditingController(text: widget.user.username);
    _namesCtrl     = TextEditingController(text: widget.user.names);
    _lastnamesCtrl = TextEditingController(text: widget.user.lastnames);
    _emailCtrl     = TextEditingController(text: widget.user.email);
    _phoneCtrl     = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _namesCtrl.dispose();
    _lastnamesCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Guardar cambios?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: const Text(
          'Se actualizarán los datos de tu perfil.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirmar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!mounted || confirm != true) return;

    Navigator.pop(
      context,
      User(
        id:        widget.user.id,
        username:  _usernameCtrl.text.trim(),
        names:     _namesCtrl.text.trim(),
        lastnames: _lastnamesCtrl.text.trim(),
        email:     _emailCtrl.text.trim(),
        phone:     _phoneCtrl.text.trim(),
        role:      widget.user.role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Editar perfil',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _field(_usernameCtrl,  'Usuario',   validator: _validateUsername),
              const SizedBox(height: 12),
              _field(_namesCtrl,     'Nombre'),
              const SizedBox(height: 12),
              _field(_lastnamesCtrl, 'Apellidos'),
              const SizedBox(height: 12),
              _field(_emailCtrl,     'Correo',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail),
              const SizedBox(height: 12),
              _field(_phoneCtrl,     'Telefono',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar cambios'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label es obligatorio.';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  String? _validateUsername(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'El usuario es obligatorio.';
    if (text.length < 3) return 'Minimo 3 caracteres.';
    if (text.contains(' ')) return 'No puede contener espacios.';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(text)) {
      return 'Solo letras, numeros y guion bajo.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'El correo es obligatorio.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }
}
