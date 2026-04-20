import 'package:flutter/material.dart';
import 'package:tocitech/pages/login_page.dart';
import '../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _aceptaTerminos = false;

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
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32),
                    Text("Crea tu cuenta",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text("Completa los datos para registrarte",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),

                    SizedBox(height: 28),

                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.surface,
                            child: Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.textSecondary
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.background, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28),

                    _label("Nombre de usuario"),
                    SizedBox(height: 8),
                    _inputField(hint: "Ej: JuanTech", icon: Icons.person_outline),

                    SizedBox(height: 18),

                    _label("Correo electrónico"),
                    SizedBox(height: 8),
                    _inputField(hint: "correo@ejemplo.com", icon: Icons.email_outlined),

                    SizedBox(height: 18),

                    _label("Teléfono (opcional)"),
                    SizedBox(height: 8),
                    _inputField(hint: "+52 000 000 0000", icon: Icons.phone_outlined),

                    SizedBox(height: 18),

                    _label("Contraseña"),
                    SizedBox(height: 8),
                    _inputField(
                      hint: "Mínimo 8 caracteres",
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    SizedBox(height: 18),

                    _label("Confirmar contraseña"),
                    SizedBox(height: 8),
                    _inputField(
                      hint: "Repite tu contraseña",
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Términos y condiciones
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _aceptaTerminos,
                            onChanged: (val) => setState(() => _aceptaTerminos = val!),
                            activeColor: AppColors.primary,
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              children: [
                                TextSpan(text: "Acepto los "),
                                TextSpan(
                                  text: "Términos y condiciones",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: " y la "),
                                TextSpan(
                                  text: "Política de privacidad",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 28),

                    // Botón registrar
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: FilledButton(
                        onPressed: _aceptaTerminos ? () {
                          Navigator.push(context, MaterialPageRoute(builder: (x) => LoginPage()));
                        } : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text("Crear cuenta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Ya tengo cuenta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("¿Ya tienes cuenta? ",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text("Inicia sesión",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),
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
      padding: EdgeInsets.fromLTRB(16, 20, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          ),
          Expanded(
            child: Center(
              child: Text("Registro",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: TextStyle(
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        obscureText: obscure,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}