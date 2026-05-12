import 'package:flutter/material.dart';
import '../../../services/ai_service.dart';
import '../../../theme/app_theme.dart';

// Modelo mensaje
class _Mensaje {
  final String texto;
  final bool esUsuario;

  _Mensaje({
    required this.texto,
    required this.esUsuario,
  });
}

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final AiService _aiService = AiService();

  bool _loading = false;

  final List<_Mensaje> _mensajes = [
    _Mensaje(
      texto:
      "¡Hola! Soy el asistente virtual de TociTech 👋\n\n"
          "Puedo ayudarte con:\n"
          "• Productos disponibles\n"
          "• Servicios y reparaciones\n"
          "• Precios\n"
          "• Horarios\n"
          "• Garantías\n\n"
          "¿Qué deseas consultar?",
      esUsuario: false,
    ),
  ];

  final List<String> _sugerencias = [
    "¿Cuáles son sus horarios?",
    "¿Qué laptops tienen?",
    "¿Hacen reparaciones?",
    "¿Cuánto cuesta un diagnóstico?",
  ];

  // =========================
  // ENVIAR MENSAJE
  // =========================

  Future<void> _sendMessage([String? text]) async {

    final message = text ?? _controller.text.trim();

    if (message.isEmpty || _loading) return;

    FocusScope.of(context).unfocus();

    setState(() {

      _mensajes.add(
        _Mensaje(
          texto: message,
          esUsuario: true,
        ),
      );

      _loading = true;
    });

    _controller.clear();

    _scrollToBottom();

    try {

      final reply = await _aiService.sendMessage(message);

      setState(() {

        _mensajes.add(
          _Mensaje(
            texto: reply,
            esUsuario: false,
          ),
        );

      });

    } catch (e) {
      print("❌ ERROR: $e"); // ← ver en consola
      setState(() {
        _mensajes.add(
          _Mensaje(
            texto: 'Error: $e', // ← ver en el chat
            esUsuario: false,
          ),
        );
      });
    } finally {

      setState(() {
        _loading = false;
      });

      _scrollToBottom();
    }
  }

  // =========================
  // SCROLL
  // =========================

  void _scrollToBottom() {

    Future.delayed(const Duration(milliseconds: 100), () {

      if (_scrollController.hasClients) {

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );

      }

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: _buildAppBar(context),

      body: Column(
        children: [

          // CHAT
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),

              itemCount: _mensajes.length + (_loading ? 1 : 0),

              itemBuilder: (context, index) {

                // Loading IA
                if (_loading && index == _mensajes.length) {

                  return _buildMensaje(
                    _Mensaje(
                      texto: "Escribiendo...",
                      esUsuario: false,
                    ),
                  );
                }

                return _buildMensaje(_mensajes[index]);
              },
            ),
          ),

          // SUGERENCIAS
          if (_mensajes.length <= 2)
            _buildSugerencias(),

          // INPUT
          _buildInput(),
        ],
      ),
    );
  }

  // =========================
  // APPBAR
  // =========================

  PreferredSizeWidget _buildAppBar(BuildContext context) {

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,

      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),

        onPressed: () => Navigator.pop(context),
      ),

      title: Row(
        children: [

          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.blue.withOpacity(0.15),

            child: const Icon(
              Icons.smart_toy,
              color: AppColors.blue,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Asistente TociTech",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                "En línea",
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // MENSAJE
  // =========================

  Widget _buildMensaje(_Mensaje mensaje) {

    final esUsuario = mensaje.esUsuario;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        mainAxisAlignment:
        esUsuario
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,

        crossAxisAlignment: CrossAxisAlignment.end,

        children: [

          // Avatar IA
          if (!esUsuario) ...[

            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.blue.withOpacity(0.15),

              child: const Icon(
                Icons.smart_toy,
                color: AppColors.blue,
                size: 16,
              ),
            ),

            const SizedBox(width: 8),
          ],

          // Burbuja
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color:
                esUsuario
                    ? AppColors.primary
                    : AppColors.surface,

                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),

                  bottomLeft:
                  Radius.circular(esUsuario ? 18 : 4),

                  bottomRight:
                  Radius.circular(esUsuario ? 4 : 18),
                ),
              ),

              child: Text(
                mensaje.texto,

                style: TextStyle(
                  color:
                  esUsuario
                      ? Colors.white
                      : AppColors.textPrimary,

                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // Avatar usuario
          if (esUsuario) ...[

            const SizedBox(width: 8),

            CircleAvatar(
              radius: 16,
              backgroundColor:
              AppColors.primary.withOpacity(0.15),

              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // SUGERENCIAS
  // =========================

  Widget _buildSugerencias() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Padding(
            padding: const EdgeInsets.only(bottom: 8),

            child: Text(
              "Preguntas frecuentes",

              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children: _sugerencias.map((s) {

              return GestureDetector(

                onTap: () => _sendMessage(s),

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                    ),
                  ),

                  child: Text(
                    s,

                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  // =========================
  // INPUT
  // =========================

  Widget _buildInput() {

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),

      decoration: BoxDecoration(
        color: AppColors.surface,

        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),

      child: Row(
        children: [

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),

                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),

              child: TextField(
                controller: _controller,

                onSubmitted: (_) => _sendMessage(),

                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),

                decoration: InputDecoration(
                  hintText: "Escribe tu pregunta...",

                  hintStyle: TextStyle(
                    color:
                    AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 14,
                  ),

                  border: InputBorder.none,

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Botón enviar
          GestureDetector(

            onTap: _sendMessage,

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              height: 46,
              width: 46,

              decoration: BoxDecoration(
                color:
                _loading
                    ? AppColors.blue.withOpacity(0.5)
                    : AppColors.blue,

                shape: BoxShape.circle,
              ),

              child:
              _loading
                  ? const Padding(
                padding: EdgeInsets.all(12),

                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )

                  : const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}