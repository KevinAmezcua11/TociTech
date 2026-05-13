import 'package:flutter/material.dart';
import 'package:tocitech/ui/pages/main/mis_pedidos_page.dart';
import '../../../database/local/session_local_service.dart';
import '../../../theme/app_theme.dart';
import '../auth/login_page.dart';
import '../../widgets/app_snackbar.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  String notificacionSeleccionada = 'ninguna';
  String aparienciaSeleccionada   = 'oscuro';

  // Datos del usuario cargados de SQLite
  String _username  = '';
  String _nombres   = '';
  String _email     = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final session = await SessionLocalService.getSession();
    if (session != null && mounted) {
      setState(() {
        _username = session['username'] as String? ?? '';
        _nombres  = '${session['names'] ?? ''} ${session['lastnames'] ?? ''}'.trim();
        _email    = session['email'] as String? ?? '';
      });
    }
  }

  // ── Diálogo genérico de edición con validación ──────────────────
  Future<void> _mostrarDialogoEdicion({
    required String titulo,
    required String labelCampo,
    required String valorActual,
    String? hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String)? validator,
    Future<void> Function(String)? onGuardar,
  }) async {
    final controller = TextEditingController(text: valorActual);
    String? error;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                titulo,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labelCampo,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: error != null
                            ? Colors.redAccent
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      obscureText: obscure,
                      keyboardType: keyboardType,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                      onChanged: (_) =>
                          setDialogState(() => error = null),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.4),
                            fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.redAccent, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(error!,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar',
                      style:
                          TextStyle(color: AppColors.textSecondary)),
                ),
                FilledButton(
                  onPressed: () async {
                    final valor = controller.text.trim();
                    final err = validator?.call(valor);
                    if (err != null) {
                      setDialogState(() => error = err);
                      return;
                    }
                    Navigator.pop(ctx);
                    await onGuardar?.call(valor);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }

  // ── Diálogo cambio de contraseña (campos separados) ──────────────
  Future<void> _mostrarDialogoCambiarPassword() async {
    final actualCtrl  = TextEditingController();
    final nuevaCtrl   = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? errorActual, errorNueva, errorConfirm;
    bool loading = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Cambiar contraseña',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(
                    ctx: ctx,
                    controller: actualCtrl,
                    label: 'Contraseña actual',
                    obscure: true,
                    error: errorActual,
                    onChanged: (_) => setS(() => errorActual = null),
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    ctx: ctx,
                    controller: nuevaCtrl,
                    label: 'Nueva contraseña',
                    hint: 'Mínimo 8 caracteres',
                    obscure: true,
                    error: errorNueva,
                    onChanged: (_) => setS(() => errorNueva = null),
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    ctx: ctx,
                    controller: confirmCtrl,
                    label: 'Confirmar contraseña',
                    obscure: true,
                    error: errorConfirm,
                    onChanged: (_) => setS(() => errorConfirm = null),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style:
                        TextStyle(color: AppColors.textSecondary)),
              ),
              FilledButton(
                onPressed: loading
                    ? null
                    : () async {
                        String? eActual, eNueva, eConfirm;
                        if (actualCtrl.text.isEmpty)
                          eActual = 'Ingresa tu contraseña actual';
                        if (nuevaCtrl.text.length < 8)
                          eNueva = 'Mínimo 8 caracteres';
                        if (confirmCtrl.text != nuevaCtrl.text)
                          eConfirm = 'Las contraseñas no coinciden';

                        if (eActual != null ||
                            eNueva != null ||
                            eConfirm != null) {
                          setS(() {
                            errorActual  = eActual;
                            errorNueva   = eNueva;
                            errorConfirm = eConfirm;
                          });
                          return;
                        }

                        setS(() => loading = true);
                        await Future.delayed(
                            const Duration(milliseconds: 400));
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          AppSnackbar.success(
                              context, 'Contraseña actualizada correctamente');
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );

    actualCtrl.dispose();
    nuevaCtrl.dispose();
    confirmCtrl.dispose();
  }

  // ── Campo reutilizable para diálogos ──────────────────────────────
  Widget _dialogField({
    required BuildContext ctx,
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscure = false,
    String? error,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: error != null
                  ? Colors.redAccent
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.4),
                  fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 12),
              const SizedBox(width: 4),
              Text(error,
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 11)),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Ajustes',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Perfil y Seguridad',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF2A2A35),
                  child: const Icon(Icons.person,
                      size: 60, color: Colors.white70),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Estadísticas del usuario
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_nombres.isNotEmpty)
                              Text(
                                _nombres,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            if (_email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _email,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_username.isNotEmpty)
                        Text(
                          '@$_username',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 16),

                      // Opciones de perfil con acción
                      _opcionPerfil(
                        'Cambiar nombre de usuario',
                        Icons.person_outline,
                        onTap: () => _mostrarDialogoEdicion(
                          titulo: 'Cambiar nombre de usuario',
                          labelCampo: 'Nuevo nombre de usuario',
                          valorActual: _username,
                          hint: 'Solo letras, números y _',
                          validator: (v) {
                            if (v.isEmpty)
                              return 'El campo es obligatorio';
                            if (v.length < 3) return 'Mínimo 3 caracteres';
                            if (v.contains(' '))
                              return 'No puede contener espacios';
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v))
                              return 'Solo letras, números y guion bajo';
                            return null;
                          },
                          onGuardar: (v) async {
                            setState(() => _username = v);
                            AppSnackbar.success(
                                context, 'Nombre de usuario actualizado');
                          },
                        ),
                      ),
                      _opcionPerfil(
                        'Cambiar contraseña',
                        Icons.lock_outline,
                        onTap: _mostrarDialogoCambiarPassword,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 140,
                        height: 32,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MisPedidosPage()),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AppColors.textMuted),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.more_horiz,
                              color: AppColors.textPrimary,
                              size: 20),
                          label: const Text(
                            'Mis pedidos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            const Text(
              'Preferencia de notificación',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _radioNotificacion('reparaciones', 'Reparaciones'),
            _radioNotificacion('compras', 'Compras'),
            _radioNotificacion('ninguna', 'Ninguna'),

            const SizedBox(height: 50),

            const Text(
              'Apariencia',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _selectorApariencia('oscuro', 'Oscuro'),
                const SizedBox(width: 30),
                _selectorApariencia('claro', 'Claro'),
              ],
            ),

            const SizedBox(height: 50),

            Divider(color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmarCierreSesion(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Colors.red.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 20),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _confirmarCierreSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Cerrar sesión?',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style:
                    TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _opcionPerfil(String texto, IconData icon,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Icon(icon,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(texto,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14)),
              const Spacer(),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioNotificacion(String valor, String texto) {
    return RadioListTile(
      value: valor,
      groupValue: notificacionSeleccionada,
      activeColor: AppColors.primary,
      onChanged: (value) =>
          setState(() => notificacionSeleccionada = value.toString()),
      title: Text(texto,
          style: const TextStyle(color: AppColors.textPrimary)),
    );
  }

  Widget _selectorApariencia(String valor, String texto) {
    final bool sel = aparienciaSeleccionada == valor;
    return GestureDetector(
      onTap: () => setState(() => aparienciaSeleccionada = valor),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: valor == 'oscuro'
                  ? AppColors.background
                  : const Color(0xFFBDBDEB),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: sel ? AppColors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(texto,
              style: const TextStyle(
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

