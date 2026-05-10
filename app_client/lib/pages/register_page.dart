import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tocitech/services/api_client.dart';
import 'package:tocitech/services/auth_service.dart';
import 'package:tocitech/utils/app_snackbar.dart';

import '../theme/app_theme.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _namesController = TextEditingController();
  final _lastnamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _saving = false;
  bool _showTermsError = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

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
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'Crea tu cuenta',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Completa los datos para registrarte',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.surface,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _label('Nombre de usuario'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _usernameController,
                        hint: 'Ej: juantech',
                        icon: Icons.person_outline,
                        validator: _validateUsername,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),
                      _label('Nombre'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _namesController,
                        hint: 'Juan',
                        icon: Icons.badge_outlined,
                        validator: (value) =>
                            _validateText(value, 'El nombre', 2, 60),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),
                      _label('Apellidos'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _lastnamesController,
                        hint: 'Perez Lopez',
                        icon: Icons.badge_outlined,
                        validator: (value) =>
                            _validateText(value, 'Los apellidos', 2, 80),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),
                      _label('Correo electronico'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _emailController,
                        hint: 'correo@ejemplo.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),
                      _label('Telefono'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _phoneController,
                        hint: '+52 000 000 0000',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\s-]'),
                          ),
                          LengthLimitingTextInputFormatter(18),
                        ],
                        validator: _validatePhone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),
                      _label('Contrasena'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _passwordController,
                        hint: 'Minimo 8 caracteres',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        validator: _validatePassword,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _label('Confirmar contrasena'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _confirmController,
                        hint: 'Repite tu contrasena',
                        icon: Icons.lock_outline,
                        obscure: _obscureConfirm,
                        validator: _validateConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) => setState(() {
                                _acceptTerms = value ?? false;
                                if (_acceptTerms) _showTermsError = false;
                              }),
                              activeColor: AppColors.primary,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Acepto los terminos y condiciones y la politica de privacidad.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_showTermsError)
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 34),
                          child: Text(
                            'Debes aceptar los terminos para crear tu cuenta.',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Crear cuenta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Ya tienes cuenta? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Inicia sesion',
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Registro',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
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
    required String? Function(String?) validator,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        errorMaxLines: 2,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
    );
  }

  String? _validateUsername(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return 'Ingresa un nombre de usuario.';
    if (clean.length < 3) return 'El usuario debe tener al menos 3 caracteres.';
    if (clean.length > 30) return 'El usuario no debe superar 30 caracteres.';
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(clean)) {
      return 'Usa solo letras, numeros, punto, guion o guion bajo.';
    }
    return null;
  }

  String? _validateText(String? value, String label, int min, int max) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return '$label es obligatorio.';
    if (clean.length < min) {
      return '$label debe tener al menos $min caracteres.';
    }
    if (clean.length > max) return '$label no debe superar $max caracteres.';
    return null;
  }

  String? _validateEmail(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return 'Ingresa tu correo electronico.';
    if (clean.length > 100) return 'El correo no debe superar 100 caracteres.';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(clean)) return 'Ingresa un correo valido.';
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Ingresa tu telefono.';
    if (digits.length < 10 || digits.length > 15) {
      return 'Ingresa un telefono valido de 10 a 15 digitos.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final clean = value ?? '';
    if (clean.isEmpty) return 'Ingresa una contrasena.';
    if (clean.length < 8) {
      return 'La contrasena debe tener al menos 8 caracteres.';
    }
    if (clean.length > 72) {
      return 'La contrasena no debe superar 72 caracteres.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(clean) ||
        !RegExp(r'\d').hasMatch(clean)) {
      return 'Usa al menos una letra y un numero.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Confirma tu contrasena.';
    if (value != _passwordController.text) {
      return 'Las contrasenas no coinciden.';
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _showTermsError = !_acceptTerms;
    });

    final validForm = _formKey.currentState?.validate() ?? false;
    if (!validForm || !_acceptTerms) return;

    setState(() => _saving = true);

    try {
      await authService.register(
        username: _usernameController.text,
        password: _passwordController.text,
        names: _namesController.text,
        lastnames: _lastnamesController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      if (!mounted) return;
      AppSnackBar.success(context, 'Cuenta creada. Ahora inicia sesion.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on ApiException catch (error) {
      if (mounted) AppSnackBar.error(context, error.userMessage);
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(
          context,
          'No se pudo crear la cuenta. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
