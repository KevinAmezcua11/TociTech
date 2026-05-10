import 'package:flutter/material.dart';

import '../models/service_model.dart';
import '../services/services_repository.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  final ServicesRepository _repository = ServicesRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-service',
        backgroundColor: AppColors.blue,
        onPressed: () => _openServiceForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<ServiceModel>>(
        stream: _repository.watchServices(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message:
                  'No se pudieron cargar los servicios. Revisa la conexion con Firebase.',
              onRetry: () => setState(() {}),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: services.length + 1,
            separatorBuilder: (_, index) => index == 0
                ? const SizedBox(height: 20)
                : const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeader(services.length);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ServiceCard(
                  service: services[index - 1],
                  onEdit: () => _openServiceForm(service: services[index - 1]),
                  onDelete: () => _confirmDelete(services[index - 1]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nuestros Servicios',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total == 0
                ? 'No hay servicios registrados todavia.'
                : '$total servicios disponibles actualizados en tiempo real.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
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
            await _repository.createService(value);
          } else {
            await _repository.updateService(value);
          }
        },
      ),
    );

    if (!mounted || saved != true) return;
    _showMessage(
      service == null ? 'Servicio creado.' : 'Servicio actualizado.',
    );
  }

  Future<void> _confirmDelete(ServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Eliminar servicio',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Deseas eliminar "${service.name}"? Esta accion no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.deleteService(service.id);
      if (mounted) _showMessage('Servicio eliminado.');
    } catch (error) {
      if (mounted) _showMessage(_errorMessage(error), isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (isError) {
      AppSnackBar.error(context, message);
    } else {
      AppSnackBar.success(context, message);
    }
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
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _nameController = TextEditingController(text: service?.name ?? '');
    _descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    _priceController = TextEditingController(
      text: service == null ? '' : service.price.toStringAsFixed(2),
    );
    _durationController = TextEditingController(text: service?.duration ?? '');
    _active = service?.active ?? true;
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
        autovalidateMode: _autovalidateMode,
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
              _field(
                _nameController,
                'Nombre',
                maxLength: 80,
                validator: (value) => _validateText(value, 'El nombre', 3, 80),
              ),
              const SizedBox(height: 12),
              _field(
                _descriptionController,
                'Descripcion',
                maxLines: 3,
                maxLength: 300,
                validator: (value) =>
                    _validateText(value, 'La descripcion', 10, 300),
              ),
              const SizedBox(height: 12),
              _field(
                _priceController,
                'Precio',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                maxLength: 12,
                validator: _validatePrice,
              ),
              const SizedBox(height: 12),
              _field(
                _durationController,
                'Duracion',
                maxLength: 60,
                validator: (value) =>
                    _validateText(value, 'La duracion', 2, 60),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Servicio activo',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
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
                  label: Text(
                    widget.service == null
                        ? 'Crear servicio'
                        : 'Guardar cambios',
                  ),
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
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label es obligatorio.';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        counterStyle: TextStyle(color: AppColors.textMuted),
        errorMaxLines: 2,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String? _validatePrice(String? value) {
    final price = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (price == null || price < 0) {
      return 'El precio debe ser un numero valido mayor o igual a cero.';
    }
    if (price > 1000000) {
      return 'El precio no debe superar 1,000,000 MXN.';
    }
    return null;
  }

  String? _validateText(String? value, String label, int min, int max) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return '$label es obligatorio.';
    if (clean.length < min) {
      return '$label debe tener al menos $min caracteres.';
    }
    if (clean.length > max) return '$label no debe superar $max caracteres.';
    return null;
  }

  Future<void> _save() async {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final service = ServiceModel(
      id: widget.service?.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text.trim().replaceAll(',', '.')),
      duration: _durationController.text,
      active: _active,
    );

    try {
      await widget.onSave(service);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.error(context, _errorMessage(error));
      setState(() => _saving = false);
    }
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.handyman_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  service.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_rounded, color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            service.description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                color: AppColors.green,
                size: 16,
              ),
              Text(
                '${service.price.toStringAsFixed(2)} MXN',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 14),
              Icon(Icons.schedule_rounded, color: AppColors.blue, size: 16),
              Expanded(
                child: Text(
                  service.duration,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Chip(
                label: Text(service.active ? 'Activo' : 'Inactivo'),
                backgroundColor: service.active
                    ? AppColors.green.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.08),
                labelStyle: TextStyle(
                  color: service.active ? AppColors.green : AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 42,
            ),
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
