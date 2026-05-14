import 'package:flutter/material.dart';

import '../../../models/service_model.dart';
import '../../../services/service_service.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/service_card.dart';
import 'service_detail_page.dart';

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  late final ServiceService _serviceService;

  List<ServiceModel> _services = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _serviceService = ServiceService(ApiService());
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _serviceService.getServices();
      setState(() => _services = data.where((s) => s.active).toList());
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _fetchServices,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _fetchServices);
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildHero(),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 240,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/fondo_servicios.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Explora Nuestro Catálogo',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _services.isEmpty
                        ? 'No hay servicios disponibles.'
                        : '${_services.length} servicio${_services.length != 1 ? "s" : ""} disponibles',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          children: [
            Icon(Icons.handyman_outlined, color: AppColors.textMuted, size: 48),
            SizedBox(height: 16),
            Text(
              'Sin servicios registrados',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          for (int i = 0; i < _services.length; i++) ...[
            ServiceCard(
              service: _services[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceDetailPage(service: _services[i]),
                ),
              ),
            ),
            if (i < _services.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Future<void> _openServiceForm({ServiceModel? service}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ServiceForm(
        service: service,
        onSave: (value) async {
          if (service == null) {
            await _serviceService.createService(value);
          } else {
            await _serviceService.updateService(service.id, value);
          }
        },
      ),
    );

    if (!mounted || saved != true) return;
    _showMessage(service == null ? 'Servicio creado.' : 'Servicio actualizado.');
    _fetchServices();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.green,
      ),
    );
  }
}

class _ServiceForm extends StatefulWidget {
  const _ServiceForm({required this.service, required this.onSave});

  final ServiceModel? service;
  final Future<void> Function(ServiceModel service) onSave;

  @override
  State<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<_ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late bool _active;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _nameController        = TextEditingController(text: service?.name ?? '');
    _descriptionController = TextEditingController(text: service?.description ?? '');
    _priceController       = TextEditingController(
      text: service == null ? '' : service.price.toStringAsFixed(2),
    );
    _durationController    = TextEditingController(text: service?.duration ?? '');
    _active                = service?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.service == null ? 'Nuevo servicio' : 'Editar servicio',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _field(_nameController, 'Nombre'),
              const SizedBox(height: 12),
              _field(_descriptionController, 'Descripcion', maxLines: 3),
              const SizedBox(height: 12),
              _field(
                _priceController,
                'Precio',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePrice,
              ),
              const SizedBox(height: 12),
              _field(_durationController, 'Duracion'),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                activeColor: AppColors.primary,
                title: Text('Servicio activo', style: TextStyle(color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(widget.service == null ? 'Crear servicio' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label es obligatorio.';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String? _validatePrice(String? value) {
    final price = double.tryParse((value ?? '').trim());
    if (price == null || price < 0) {
      return 'El precio debe ser un numero valido mayor o igual a cero.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final service = ServiceModel(
      id:          widget.service?.id ?? '',
      name:        _nameController.text,
      description: _descriptionController.text,
      price:       double.parse(_priceController.text.trim()),
      duration:    _durationController.text,
      active:      _active,
    );

    try {
      await widget.onSave(service);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage(error)),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _saving = false);
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _errorMessage(Object error) {
  if (error is ArgumentError) return error.message.toString();
  return 'No se pudo completar la operacion. Revisa la conexion e intenta de nuevo.';
}
