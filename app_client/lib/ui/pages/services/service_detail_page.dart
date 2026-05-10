import 'package:flutter/material.dart';
import '../../../database/local/session_local_service.dart';
import '../../../models/service_model.dart';
import '../../../services/api_service.dart';
import '../../../services/order_service.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';

class ServiceDetailPage extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  bool _equipmentError = false;
  String? _equipmentErrorMsg;
  bool _problemError = false;
  String? _problemErrorMsg;
  bool _loading = false;

  ServiceModel get service => widget.service;

  @override
  void dispose() {
    _equipmentController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  bool _validateEquipment() {
    final text = _equipmentController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _equipmentError = true;
        _equipmentErrorMsg = 'Este campo es obligatorio.';
      });
      return false;
    }
    setState(() {
      _equipmentError = false;
      _equipmentErrorMsg = null;
    });
    return true;
  }

  bool _validateProblem() {
    final text = _problemController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _problemError = true;
        _problemErrorMsg = 'Este campo es obligatorio.';
      });
      return false;
    }
    if (text.length < 10) {
      setState(() {
        _problemError = true;
        _problemErrorMsg =
            'Por favor describe con más detalle (mínimo 10 caracteres).';
      });
      return false;
    }
    setState(() {
      _problemError = false;
      _problemErrorMsg = null;
    });
    return true;
  }

  Future<void> _solicitarServicio() async {
    final equipmentOk = _validateEquipment();
    if (!_validateProblem() | !equipmentOk) return;

    setState(() => _loading = true);

    try {
      final session = await SessionLocalService.getSession();
      if (session == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes iniciar sesión para solicitar un servicio.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      await OrderService(ApiService()).createOrder({
        'type': 'service',
        'serviceId': service.id,
        'customerId': session['user_id'],
        'equipment': _equipmentController.text.trim(),
        'problem': _problemController.text.trim(),
      });

      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.3),
                        width: 2),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.green, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Servicio solicitado!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu solicitud fue enviada. Nos pondremos en contacto contigo pronto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Entendido',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.surface,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(
                url: service.image,
                fit: BoxFit.cover,
                loading: Container(
                  color: AppColors.surface,
                  child: const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: _placeholderHeader(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description.isEmpty
                        ? 'Sin descripción disponible.'
                        : service.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '\$${service.price.toStringAsFixed(2)} MXN',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoCard(
                    icon: Icons.schedule_rounded,
                    label: 'Tiempo estimado',
                    value: service.duration,
                    color: AppColors.blue,
                  ),

                  // ── Campo: Nombre del equipo ──────────────────────
                  const SizedBox(height: 16),
                  _equipmentField(),

                  // ── Campo: Descripción del problema ──────────────
                  const SizedBox(height: 12),
                  _problemField(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _loading ? null : _solicitarServicio,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              _loading ? 'Enviando...' : 'Solicitar servicio',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  // ── Campo de nombre del equipo ────────────────────────────────────
  Widget _equipmentField() {
    final borderColor = _equipmentError
        ? Colors.redAccent
        : Colors.white.withValues(alpha: 0.06);
    final accentColor = _equipmentError ? Colors.redAccent : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.devices_rounded, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Nombre del equipo',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _equipmentController,
            maxLines: 1,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            onChanged: (_) {
              if (_equipmentError) {
                setState(() {
                  _equipmentError = false;
                  _equipmentErrorMsg = null;
                });
              }
            },
            decoration: const InputDecoration(
              hintText: 'Ej. Laptop HP Pavilion, iPhone 13, PC de escritorio...',
              hintStyle: TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (_equipmentErrorMsg != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _equipmentErrorMsg!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Campo de descripción del problema ─────────────────────────────
  Widget _problemField() {
    final borderColor = _problemError
        ? Colors.redAccent
        : Colors.white.withValues(alpha: 0.06);
    final accentColor = _problemError ? Colors.redAccent : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.description_outlined,
                    color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Describe tu problema o situación',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _problemController,
            maxLines: 4,
            minLines: 3,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14, height: 1.5),
            onChanged: (_) {
              if (_problemError) {
                setState(() {
                  _problemError = false;
                  _problemErrorMsg = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText:
                  'Explica detalladamente qué ocurre con tu equipo o qué necesitas.',
              hintStyle: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13, height: 1.4),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (_problemErrorMsg != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _problemErrorMsg!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _placeholderHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.30),
            AppColors.blue.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.handyman_rounded,
            color: AppColors.primary, size: 72),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
