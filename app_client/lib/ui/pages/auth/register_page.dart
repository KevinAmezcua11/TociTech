import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:tocitech/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/auth_controller.dart';
import '../../widgets/app_snackbar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  late AuthController authController;

  final _usernameController  = TextEditingController();
  final _namesController     = TextEditingController();
  final _lastnamesController = TextEditingController();
  final _emailController     = TextEditingController();
  final _phoneController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _confirmController   = TextEditingController();

  // ── Errores por campo ──────────────────────────────────────────
  String? _usernameError;
  String? _namesError;
  String? _lastnamesError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;

  // ── Fortaleza de contraseña (0–4) ──────────────────────────────
  int get _passwordStrength {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    int s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[0-9]').hasMatch(p)) s++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(p)) s++;
    return s;
  }

  Color get _strengthColor => switch (_passwordStrength) {
        0 => Colors.transparent,
        1 => Colors.redAccent,
        2 => Colors.orange,
        3 => const Color(0xFFFFD54F),
        _ => AppColors.green,
      };

  String get _strengthLabel => switch (_passwordStrength) {
        0 => '',
        1 => 'Muy débil',
        2 => 'Débil',
        3 => 'Buena',
        _ => 'Fuerte',
      };

  @override
  void initState() {
    super.initState();
    authController = AuthController(AuthService());
    // Recalcula la fortaleza en tiempo real
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _namesController.dispose();
    _lastnamesController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Valida todos los campos y retorna true si todo es correcto.
  bool _validateAll() {
    String? usernameErr, namesErr, lastnamesErr, emailErr, phoneErr,
        passwordErr, confirmErr;

    final username  = _usernameController.text.trim();
    final names     = _namesController.text.trim();
    final lastnames = _lastnamesController.text.trim();
    final email     = _emailController.text.trim();
    final phone     = _phoneController.text.trim();
    final password  = _passwordController.text;
    final confirm   = _confirmController.text;

    if (username.isEmpty) {
      usernameErr = 'El nombre de usuario es obligatorio';
    } else if (username.length < 3) {
      usernameErr = 'Mínimo 3 caracteres';
    } else if (username.contains(' ')) {
      usernameErr = 'No puede contener espacios';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      usernameErr = 'Solo letras, números y guion bajo ( _ )';
    }

    if (names.isEmpty) {
      namesErr = 'El nombre es obligatorio';
    } else if (names.length < 2) {
      namesErr = 'Nombre demasiado corto';
    } else if (RegExp(r'[0-9]').hasMatch(names)) {
      namesErr = 'El nombre no puede contener números';
    }

    if (lastnames.isEmpty) {
      lastnamesErr = 'Los apellidos son obligatorios';
    } else if (lastnames.length < 2) {
      lastnamesErr = 'Apellidos demasiado cortos';
    } else if (RegExp(r'[0-9]').hasMatch(lastnames)) {
      lastnamesErr = 'Los apellidos no pueden contener números';
    }

    if (email.isEmpty) {
      emailErr = 'El correo es obligatorio';
    } else if (!RegExp(
            r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      emailErr = 'Ingresa un correo válido (ej. usuario@mail.com)';
    }

    if (phone.isEmpty) {
      phoneErr = 'El teléfono es obligatorio';
    } else if (!RegExp(r'^\d+$').hasMatch(phone)) {
      phoneErr = 'Solo se permiten números';
    } else if (phone.length < 10 || phone.length > 15) {
      phoneErr = 'Debe tener entre 10 y 15 dígitos';
    }

    if (password.isEmpty) {
      passwordErr = 'La contraseña es obligatoria';
    } else if (password.length < 8) {
      passwordErr = 'Mínimo 8 caracteres';
    } else if (_passwordStrength < 2) {
      passwordErr = 'La contraseña es muy débil. Agrega mayúsculas o números';
    }

    if (confirm.isEmpty) {
      confirmErr = 'Confirma tu contraseña';
    } else if (confirm != password) {
      confirmErr = 'Las contraseñas no coinciden';
    }

    setState(() {
      _usernameError  = usernameErr;
      _namesError     = namesErr;
      _lastnamesError = lastnamesErr;
      _emailError     = emailErr;
      _phoneError     = phoneErr;
      _passwordError  = passwordErr;
      _confirmError   = confirmErr;
    });

    return [usernameErr, namesErr, lastnamesErr, emailErr, phoneErr,
            passwordErr, confirmErr].every((e) => e == null);
  }

  void _register() async {
    if (!_validateAll()) return;

    try {
      setState(() => _loading = true);

      final success = await authController.register(
        username:  _usernameController.text.trim().toLowerCase(),
        password:  _passwordController.text,
        names:     _namesController.text.trim(),
        lastnames: _lastnamesController.text.trim(),
        email:     _emailController.text.trim(),
        phone:     _phoneController.text.trim(),
      );

      if (!success) {
        setState(() => _loading = false);
        _showError(authController.errorMessage ?? 'Error al registrar');
        return;
      }

      AppSnackbar.success(context, 'Cuenta creada correctamente');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      setState(() => _loading = false);
      _showError('Error al registrar usuario');
    }
  }

  void _showError(String msg) {
    AppSnackbar.error(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    const Text("Crea tu cuenta",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        )),

                    const SizedBox(height: 6),

                    const Text("Completa los datos para registrarte",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),

                    const SizedBox(height: 28),

                    /// Avatar
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.surface,
                            child: const Icon(Icons.person, size: 50, color: AppColors.textSecondary),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.background, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// USERNAME
                    _label("Nombre de usuario"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Nombre de usuario",
                      icon: Icons.person,
                      controller: _usernameController,
                      errorText: _usernameError,
                      onChanged: (_) => setState(() => _usernameError = null),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 18),

                    /// NOMBRE
                    _label("Nombre(s)"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Nombre",
                      icon: Icons.person_outline,
                      controller: _namesController,
                      errorText: _namesError,
                      onChanged: (_) => setState(() => _namesError = null),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 18),

                    /// APELLIDOS
                    _label("Apellidos"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Apellidos",
                      icon: Icons.person_outline,
                      controller: _lastnamesController,
                      errorText: _lastnamesError,
                      onChanged: (_) =>
                          setState(() => _lastnamesError = null),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 18),

                    /// EMAIL
                    _label("Correo electrónico"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Correo electrónico",
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() => _emailError = null),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 18),

                    /// TELÉFONO
                    _label("Teléfono"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "10 dígitos",
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() => _phoneError = null),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 18),

                    /// PASSWORD
                    _label("Contraseña"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Mínimo 8 caracteres",
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      controller: _passwordController,
                      errorText: _passwordError,
                      onChanged: (_) => setState(() => _passwordError = null),
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    // ── Indicador de fortaleza ──────────────────────
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _passwordStrength / 4,
                                backgroundColor:
                                    Colors.white.withOpacity(0.08),
                                color: _strengthColor,
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                                color: _strengthColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 18),

                    /// CONFIRM PASSWORD
                    _label("Confirmar contraseña"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Confirmar contraseña",
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirm,
                      controller: _confirmController,
                      errorText: _confirmError,
                      onChanged: (_) =>
                          setState(() => _confirmError = null),
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 28),

                    /// BOTÓN
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _loading ? null : _register,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text("Crear cuenta"),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿Ya tienes cuenta? ",
                            style: TextStyle(color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text("Inicia sesión",
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          ),
          const Expanded(
            child: Center(
              child: Text("Registro",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? Colors.redAccent
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            textAlignVertical: TextAlignVertical.center,
            style:
                const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon:
                  Icon(icon, color: AppColors.textSecondary),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}