import 'package:flutter/material.dart';
import 'package:tocitech/pages/mis_pedidos_page.dart';
import 'package:tocitech/pages/reparaciones_page.dart';
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
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text("Ajustes",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: 40),

            Text("Perfil y Seguridad",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 25),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFF2A2A35),
                  child: Icon(Icons.person, size: 60, color: Colors.white70),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("Reparaciones: 3\nCompras: 5",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text("Juanito03",
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      _opcionPerfil("Cambiar foto de perfil"),
                      _opcionPerfil("Cambiar nombre de usuario"),
                      _opcionPerfil("Cambiar contraseña"),
                      _opcionPerfil("Autenticación en dos pasos"),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 140, height: 32,
                        child: OutlinedButton.icon(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (x) => MisPedidosPage()));
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.textMuted),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: Icon(Icons.more_horiz, color: AppColors.textPrimary, size: 20),
                          label: Text("Mas detalles",
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

            SizedBox(height: 50),

            Text("Preferencia de notificación",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            _radioNotificacion("reparaciones", "Reparaciones"),
            _radioNotificacion("compras", "Compras"),
            _radioNotificacion("ninguna", "Ninguna"),

            SizedBox(height: 50),

            Text("Apariencia",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _selectorApariencia("oscuro", "Oscuro"),
                SizedBox(width: 30),
                _selectorApariencia("claro", "Claro"),
              ],
            ),

            SizedBox(height: 50),

            // Cerrar sesión
            Divider(color: Colors.white.withOpacity(0.08)),
            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmarCierreSesion(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                label: Text("Cerrar sesión",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),
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
        backgroundColor: Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("¿Cerrar sesión?", textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
                    (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _opcionPerfil(String texto) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(texto, style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
    );
  }

  Widget _radioNotificacion(String valor, String texto) {
    return RadioListTile(
      value: valor,
      groupValue: notificacionSeleccionada,
      activeColor: AppColors.primary,
      onChanged: (value) => setState(() => notificacionSeleccionada = value.toString()),
      title: Text(texto, style: TextStyle(color: AppColors.textPrimary)),
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
              color: valor == "oscuro" ? AppColors.background : Color(0xFFBDBDEB),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: seleccionado ? AppColors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(texto, style: TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}