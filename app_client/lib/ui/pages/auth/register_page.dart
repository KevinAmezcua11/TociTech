import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:tocitech/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _aceptaTerminos = false;
  bool _loading = false;

  late AuthController authController;

  final _usernameController = TextEditingController();
  final _namesController = TextEditingController();
  final _lastnamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();

    authController = AuthController(AuthService());
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

  void _register() async {
    if (_usernameController.text.isEmpty ||
        _namesController.text.isEmpty ||
        _lastnamesController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Completa todos los campos obligatorios");
      return;
    }

    if (_passwordController.text.length < 8) {
      _showError("La contraseña debe tener al menos 8 caracteres");
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showError("Las contraseñas no coinciden");
      return;
    }

    try {
      setState(() => _loading = true);

      final success = await authController.register(
        username: _usernameController.text.trim().toLowerCase(),
        password: _passwordController.text,
        names: _namesController.text,
        lastnames: _lastnamesController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      if (!success) {
        setState(() => _loading = false);
        _showError(authController.errorMessage ?? "Error al registrar");
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cuenta creada correctamente")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );

    } catch (e) {
      setState(() => _loading = false);
      _showError("Error al registrar usuario");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
                    ),

                    const SizedBox(height: 18),

                    /// NOMBRE
                    _label("Nombre(s)"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Nombre",
                      icon: Icons.person_outline,
                      controller: _namesController,
                    ),

                    const SizedBox(height: 18),

                    /// APELLIDOS
                    _label("Apellidos"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Apellidos",
                      icon: Icons.person_outline,
                      controller: _lastnamesController,
                    ),

                    const SizedBox(height: 18),

                    /// EMAIL
                    _label("Correo electrónico"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Correo electrónico",
                      icon: Icons.email_outlined,
                      controller: _emailController,
                    ),

                    const SizedBox(height: 18),

                    /// TELÉFONO
                    _label("Teléfono"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Teléfono",
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// CONFIRM PASSWORD
                    _label("Confirmar contraseña"),
                    const SizedBox(height: 8),
                    _inputField(
                      hint: "Confirmar contraseña",
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirm,
                      controller: _confirmController,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// CHECKBOX
                    Row(
                      children: [
                        Checkbox(
                          value: _aceptaTerminos,
                          onChanged: (val) => setState(() => _aceptaTerminos = val!),
                          activeColor: AppColors.primary,
                        ),
                        const Expanded(
                          child: Text(
                            "Acepto los términos y condiciones",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    /// BOTÓN
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: (_aceptaTerminos && !_loading) ? _register : null,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
        ),
      ),
    );
  }
}