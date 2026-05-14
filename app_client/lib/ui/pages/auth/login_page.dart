import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tocitech/app_navigator.dart';
import 'package:tocitech/controllers/auth_controller.dart';
import 'package:tocitech/services/auth_service.dart';
import 'package:tocitech/ui/pages/main/home_page.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/app_snackbar.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String? _usernameError;
  String? _passwordError;

  bool _obscurePassword = true;

  late AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = AuthController(AuthService());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Devuelve true si todo es válido, false si hay algún error.
  bool _validate() {
    String? usernameErr;
    String? passwordErr;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      usernameErr = 'El nombre de usuario es obligatorio';
    } else if (username.length < 3) {
      usernameErr = 'El usuario debe tener al menos 3 caracteres';
    } else if (username.contains(' ')) {
      usernameErr = 'El usuario no puede contener espacios';
    }

    if (password.isEmpty) {
      passwordErr = 'La contraseña es obligatoria';
    } else if (password.length < 6) {
      passwordErr = 'La contraseña debe tener al menos 6 caracteres';
    }

    setState(() {
      _usernameError = usernameErr;
      _passwordError = passwordErr;
    });

    // Mueve el foco al primer campo con error
    if (usernameErr != null) {
      _usernameFocus.requestFocus();
    } else if (passwordErr != null) {
      _passwordFocus.requestFocus();
    }

    return usernameErr == null && passwordErr == null;
  }

  Future<void> _login() async {
    if (!_validate()) return;

    final success = await authController.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() {});

    if (success) {
      authController.authService.api.onSessionExpired = () async {
        await authController.authService.logout();
        appNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      };
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TociTechApp()),
      );
    } else {
      AppSnackbar.error(
          context, authController.errorMessage ?? 'Error al iniciar sesión');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 36),

                    const Text(
                      "Bienvenido de nuevo",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Inicia sesión para continuar",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _label("Usuario"),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      hint: "Nombre de usuario",
                      icon: Icons.person_outline,
                      errorText: _usernameError,
                      onChanged: (_) =>
                          setState(() => _usernameError = null),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) =>
                          _passwordFocus.requestFocus(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9_]')),
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _label("Contraseña"),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hint: "Contraseña",
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      errorText: _passwordError,
                      onChanged: (_) =>
                          setState(() => _passwordError = null),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) =>
                          authController.isLoading ? null : _login(),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(72),
                      ],
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        ),
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: authController.isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: authController.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Iniciar sesión",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿No tienes cuenta? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          ),
                          child: const Text(
                            "Regístrate",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Image.asset("assets/Logo-img.png", height: 44),
          ),
          const SizedBox(height: 12),
          const Text(
            "TociTech",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
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
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    bool obscure = false,
    Widget? suffixIcon,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
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
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            onChanged: onChanged,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            inputFormatters: inputFormatters,
            style:
                const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              prefixIcon:
                  Icon(icon, color: AppColors.textSecondary, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
              Text(
                errorText,
                style: const TextStyle(
                    color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }
}