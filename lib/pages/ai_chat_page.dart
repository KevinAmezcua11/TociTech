import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Modelo para mensaje
class _Mensaje {
  final String texto;
  final bool esUsuario;
  _Mensaje({required this.texto, required this.esUsuario});
}

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Mensaje> _mensajes = [
    _Mensaje(
      texto: "¡Hola! Soy el asistente de TociTech 👋\n¿En qué puedo ayudarte hoy?",
      esUsuario: false,
    ),
    _Mensaje(
      texto: "¿Cuánto cuesta un diagnóstico?",
      esUsuario: true,
    ),
    _Mensaje(
      texto: "El diagnóstico técnico tiene un costo desde \$150 MXN e incluye una revisión completa de hardware y software. El tiempo estimado es de 1 a 2 días hábiles. 🔧",
      esUsuario: false,
    ),
  ];

  final List<String> _sugerencias = [
    "¿Cuáles son sus horarios?",
    "¿Hacen reparaciones de laptop?",
    "¿Tienen garantía?",
    "Ver productos disponibles",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) => _buildMensaje(_mensajes[index]),
            ),
          ),

          if (_mensajes.length <= 3) _buildSugerencias(),

          _buildInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20
        ),
        onPressed: () => Navigator.pop(context),
      ),

      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.blue.withOpacity(0.2),
            child: Icon(
                Icons.smart_toy,
                color: AppColors.blue,
                size: 20
            ),
          ),

          SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Asistente TociTech",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text("En línea",
                style: TextStyle(color: Color(0xFF22C55E), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Burbuja de Mensaje

  Widget _buildMensaje(_Mensaje mensaje) {
    final esUsuario = mensaje.esUsuario;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esUsuario) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.blue.withOpacity(0.2),
              child: const Icon(Icons.smart_toy, color: AppColors.blue, size: 16),
            ),
            const SizedBox(width: 8),
          ],

          // Burbuja
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: esUsuario ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(esUsuario ? 18 : 4),
                  bottomRight: Radius.circular(esUsuario ? 4 : 18),
                ),
              ),
              child: Text(mensaje.texto,
                style: TextStyle(
                  color: esUsuario ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // Avatar usuario
          if (esUsuario) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 16
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Sugerencias Rapidas

  Widget _buildSugerencias() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text("Preguntas frecuentes",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sugerencias.map((s) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Text(s,
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Input

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Escribe tu pregunta...",
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          SizedBox(width: 10),

          // Botón enviar
          Container(
            height: 46, width: 46,
            decoration: BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20
            ),
          ),
        ],
      ),
    );
  }
}