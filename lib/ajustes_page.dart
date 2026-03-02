import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF0F0F14),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Título principal
            const Center(
              child: Text(
                "AJUSTES",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // PERFIL Y SEGURIDAD
            const Text(
              "Perfil y Seguridad",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Avatar
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFF2A2A35),
                  child: Icon(Icons.person, size: 60, color: Colors.white70),
                ),

                const SizedBox(width: 20),

                // Info usuario
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
                        child: const Text(
                          "Reparaciones: 3\nCompras: 5",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Juanito03",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _opcionPerfil("Cambiar foto de perfil"),
                      _opcionPerfil("Cambiar nombre de usuario"),
                      _opcionPerfil("Cambiar contraseña"),
                      _opcionPerfil("Autenticación en dos pasos"),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 50),

            // PREFERENCIAS DE NOTIFICACIÓN
            const Text(
              "Preferencia de notificación",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _radioNotificacion("reparaciones", "Reparaciones"),
            _radioNotificacion("compras", "Compras"),
            _radioNotificacion("ninguna", "Ninguna"),

            const SizedBox(height: 50),

            // APARIENCIA
            const Text(
              "Apariencia",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // =========================
  // OPCIONES PERFIL
  // =========================

  Widget _opcionPerfil(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
      ),
    );
  }

  // =========================
  // RADIO BUTTONS
  // =========================

  Widget _radioNotificacion(String valor, String texto) {
    return RadioListTile(
      value: valor,
      groupValue: notificacionSeleccionada,
      activeColor: const Color(0xFF6C63FF),
      onChanged: (value) {
        setState(() {
          notificacionSeleccionada = value.toString();
        });
      },
      title: Text(
        texto,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // =========================
  // SELECTOR APARIENCIA
  // =========================

  Widget _selectorApariencia(String valor, String texto) {
    final bool seleccionado = aparienciaSeleccionada == valor;

    return GestureDetector(
      onTap: () {
        setState(() {
          aparienciaSeleccionada = valor;
        });
      },
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: valor == "oscuro"
                  ? const Color(0xFF0F0F14)
                  : const Color(0xFFBDBDEB),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: seleccionado
                    ? const Color(0xFF2979FF)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}