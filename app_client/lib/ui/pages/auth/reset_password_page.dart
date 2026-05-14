import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tocitech/services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/app_snackbar.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes =
      List.generate(6, (_) => FocusNode());

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _passwordError;
  String? _confirmError;
  String? _codeError;
  bool _loading = false;

  final _authService = AuthService();

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String get _code =>
      _codeControllers.map((c) => c.text).join();

  bool _validate() {
    final code = _code;
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    String? codeErr;
    String? passErr;
    String? confErr;

    if (code.length < 6) codeErr = 'Ingresa el código completo de 6 dígitos';

    if (password.isEmpty) {
      passErr = 'La contraseña es obligatoria';
    } else if (password.length < 8) {
      passErr = 'La contraseña debe tener al menos 8 caracteres';
    }

    if (confirm.isEmpty) {
      confErr = 'Confirma tu contraseña';
    } else if (confirm != password) {
      confErr = 'Las contraseñas no coinciden';
    }

    setState(() {
      _codeError = codeErr;
      _passwordError = passErr;
      _confirmError = confErr;
    });

    if (codeErr != null) {
      _codeFocusNodes[0].requestFocus();
    } else if (passErr != null) {
      _passwordFocus.requestFocus();
    } else if (confErr != null) {
      _confirmFocus.requestFocus();
    }

    return codeErr == null && passErr == null && confErr == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _loading = true);

    try {
      await _authService.resetPassword(
        email: widget.email,
        code: _code,
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      AppSnackbar.success(context, '¡Contraseña restablecida con éxito!');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('Invalid or expired')) {
        setState(() => _codeError = 'Código inválido o expirado');
        _codeFocusNodes[0].requestFocus();
      } else {
        AppSnackbar.error(context, 'No se pudo restablecer. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onCodeDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _codeFocusNodes[index - 1].requestFocus();
    }
    setState(() => _codeError = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.verified_user_outlined,
                    color: AppColors.primary, size: 28),
              ),

              const SizedBox(height: 24),

              const Text(
                'Verifica tu código',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Ingresa el código de 6 dígitos que enviamos a ${widget.email}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Campos del código OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _codeBox(i)),
              ),

              if (_codeError != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 13),
                    const SizedBox(width: 4),
                    Text(_codeError!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 12)),
                  ],
                ),
              ],

              const SizedBox(height: 28),

              _label('Nueva contraseña'),
              const SizedBox(height: 8),
              _passwordField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hint: 'Mínimo 8 caracteres',
                obscure: _obscurePassword,
                errorText: _passwordError,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (_) => setState(() => _passwordError = null),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _confirmFocus.requestFocus(),
              ),

              const SizedBox(height: 20),

              _label('Confirmar contraseña'),
              const SizedBox(height: 8),
              _passwordField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                hint: 'Repite la contraseña',
                obscure: _obscureConfirm,
                errorText: _confirmError,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                onChanged: (_) => setState(() => _confirmError = null),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _loading ? null : _submit(),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Restablecer contraseña',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _codeBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _codeError != null
                ? Colors.redAccent
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: TextField(
          controller: _codeControllers[index],
          focusNode: _codeFocusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _onCodeDigitChanged(index, v),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
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

  Widget _passwordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
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
            style:
                const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textSecondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
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
              Text(errorText,
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }
}
