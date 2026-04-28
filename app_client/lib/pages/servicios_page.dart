import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Servicio {
  final String id;
  final String titulo;
  final String descripcion;
  final String imagen;
  final int precio;
  final String tiempo;

  const Servicio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.precio,
    required this.tiempo,
  });

  factory Servicio.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Servicio(
      id: doc.id,
      titulo: (data['titulo'] ?? '').toString(),
      descripcion: (data['descripcion'] ?? '').toString(),
      imagen: (data['imagen'] ?? 'assets/servicio1.png').toString(),
      precio: _toInt(data['precio']),
      tiempo: (data['tiempo'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'imagen': imagen.trim(),
      'precio': precio,
      'tiempo': tiempo.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  final CollectionReference<Map<String, dynamic>> _servicesRef =
      FirebaseFirestore.instance.collection('services');

  Stream<QuerySnapshot<Map<String, dynamic>>> get _servicesStream =>
      _servicesRef.orderBy('titulo').snapshots();

  Future<void> _saveService(ServicioFormData data, {String? id}) async {
    final service = Servicio(
      id: id ?? '',
      titulo: data.titulo,
      descripcion: data.descripcion,
      imagen: data.imagen,
      precio: data.precio,
      tiempo: data.tiempo,
    );

    if (id == null) {
      await _servicesRef.add({
        ...service.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _servicesRef.doc(id).update(service.toMap());
    }
  }

  Future<void> _deleteService(Servicio servicio) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Eliminar servicio',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Se eliminara "${servicio.titulo}" de forma permanente.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
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
      await _servicesRef.doc(servicio.id).delete();
      _showMessage('Servicio eliminado.');
    } catch (_) {
      _showMessage('No se pudo eliminar el servicio.', isError: true);
    }
  }

  Future<void> _openServiceForm([Servicio? servicio]) async {
    final result = await showDialog<ServicioFormData>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ServiceFormDialog(servicio: servicio),
    );

    if (result == null) return;

    try {
      await _saveService(result, id: servicio?.id);
      _showMessage(
        servicio == null ? 'Servicio creado.' : 'Servicio actualizado.',
      );
    } catch (_) {
      _showMessage('No se pudo guardar el servicio.', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openServiceForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _servicesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _PageMessage(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar los servicios',
              message: 'Revisa tu conexion o permisos de Firestore.',
              action: TextButton(
                onPressed: () => setState(() {}),
                child: const Text('Reintentar'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services =
              snapshot.data?.docs
                  .map(Servicio.fromSnapshot)
                  .where((service) => service.titulo.isNotEmpty)
                  .toList() ??
              [];

          if (services.isEmpty) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(),
                const SizedBox(height: 80),
                _PageMessage(
                  icon: Icons.handyman_outlined,
                  title: 'Sin servicios registrados',
                  message: 'Agrega el primer servicio para mostrarlo aqui.',
                  action: FilledButton.icon(
                    onPressed: () => _openServiceForm(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Crear servicio'),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: services.length + 1,
            separatorBuilder: (_, index) => index == 0
                ? const SizedBox(height: 20)
                : const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeader();
              final service = services[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ServiceCard(
                  servicio: service,
                  onEdit: () => _openServiceForm(service),
                  onDelete: () => _deleteService(service),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: const Column(
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
          SizedBox(height: 4),
          Text(
            'Soluciones tecnicas con precios claros y accesibles.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.servicio,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.asset(
                  servicio.imagen.isEmpty
                      ? 'assets/servicio1.png'
                      : servicio.imagen,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceDark,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [AppColors.surface, Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_money_rounded,
                        color: AppColors.green,
                        size: 13,
                      ),
                      Text(
                        'Desde \$${servicio.precio} MXN',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.handyman_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        servicio.titulo,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Editar',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 19),
                      color: AppColors.blue,
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: Colors.redAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  servicio.descripcion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.blue,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${servicio.tiempo} dias habiles',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.handyman_rounded, size: 14),
                      label: const Text(
                        'Solicitar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServicioFormData {
  final String titulo;
  final String descripcion;
  final String imagen;
  final int precio;
  final String tiempo;

  const ServicioFormData({
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.precio,
    required this.tiempo,
  });
}

class _ServiceFormDialog extends StatefulWidget {
  final Servicio? servicio;

  const _ServiceFormDialog({this.servicio});

  @override
  State<_ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<_ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _imagenController;
  late final TextEditingController _precioController;
  late final TextEditingController _tiempoController;

  @override
  void initState() {
    super.initState();
    final servicio = widget.servicio;
    _tituloController = TextEditingController(text: servicio?.titulo ?? '');
    _descripcionController = TextEditingController(
      text: servicio?.descripcion ?? '',
    );
    _imagenController = TextEditingController(
      text: servicio?.imagen ?? 'assets/servicio1.png',
    );
    _precioController = TextEditingController(
      text: servicio?.precio.toString() ?? '',
    );
    _tiempoController = TextEditingController(text: servicio?.tiempo ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _imagenController.dispose();
    _precioController.dispose();
    _tiempoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        widget.servicio == null ? 'Nuevo servicio' : 'Editar servicio',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ServiceTextField(
                  controller: _tituloController,
                  label: 'Titulo',
                  icon: Icons.title_rounded,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _ServiceTextField(
                  controller: _descripcionController,
                  label: 'Descripcion',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _ServiceTextField(
                  controller: _imagenController,
                  label: 'Imagen asset',
                  icon: Icons.image_outlined,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _ServiceTextField(
                  controller: _precioController,
                  label: 'Precio',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: _priceValidator,
                ),
                const SizedBox(height: 12),
                _ServiceTextField(
                  controller: _tiempoController,
                  label: 'Tiempo en dias',
                  icon: Icons.schedule_rounded,
                  validator: _requiredValidator,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  String? _priceValidator(String? value) {
    final price = int.tryParse(value?.trim() ?? '');
    if (price == null) return 'Ingresa un numero valido';
    if (price <= 0) return 'El precio debe ser mayor a 0';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      ServicioFormData(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        imagen: _imagenController.text.trim(),
        precio: int.parse(_precioController.text.trim()),
        tiempo: _tiempoController.text.trim(),
      ),
    );
  }
}

class _ServiceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ServiceTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _PageMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _PageMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
