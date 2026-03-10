import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  String notificacionSeleccionada = "ninguna";
  String aparienciaSeleccionada = "oscuro";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text("AJUSTES",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 40),

            const Text("Perfil y Seguridad",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFF2A2A35),
                  child: Icon(Icons.person, size: 60, color: Colors.white70),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("Reparaciones: 3\nCompras: 5",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text("Juanito03",
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _opcionPerfil("Cambiar foto de perfil"),
                      _opcionPerfil("Cambiar nombre de usuario"),
                      _opcionPerfil("Cambiar contraseña"),
                      _opcionPerfil("Autenticación en dos pasos"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            const Text("Preferencia de notificación",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _radioNotificacion("reparaciones", "Reparaciones"),
            _radioNotificacion("compras", "Compras"),
            _radioNotificacion("ninguna", "Ninguna"),

            const SizedBox(height: 50),

            const Text("Apariencia",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _selectorApariencia("oscuro", "Oscuro"),
                const SizedBox(width: 30),
                _selectorApariencia("claro", "Claro"),
              ],
            ),

            const SizedBox(height: 50),

            // Cerrar sesión
            Divider(color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmarCierreSesion(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                label: const Text("Cerrar sesión",
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

  // Confirmación antes de cerrar sesión
  void _confirmarCierreSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("¿Cerrar sesión?",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text("Tendrás que volver a iniciar sesión para acceder a tu cuenta.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false, // Limpia todo el stack de navegación
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _opcionPerfil(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(texto, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
    );
  }

  Widget _radioNotificacion(String valor, String texto) {
    return RadioListTile(
      value: valor,
      groupValue: notificacionSeleccionada,
      activeColor: AppColors.primary,
      onChanged: (value) => setState(() => notificacionSeleccionada = value.toString()),
      title: Text(texto, style: const TextStyle(color: AppColors.textPrimary)),
    );
  }

  Widget _selectorApariencia(String valor, String texto) {
    final bool seleccionado = aparienciaSeleccionada == valor;
    return GestureDetector(
      onTap: () => setState(() => aparienciaSeleccionada = valor),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: valor == "oscuro" ? AppColors.background : const Color(0xFFBDBDEB),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: seleccionado ? AppColors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(texto, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}