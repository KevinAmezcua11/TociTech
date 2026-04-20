import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductDetailPage extends StatefulWidget {
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final int total;
  final String imagen;

  const ProductDetailPage({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.total,
    required this.imagen,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _cantidad = 1;
  String _accionSeleccionada = "comprar"; // comprar | apartar | reservar

  @override
  Widget build(BuildContext context) {
    final double porcentajeStock = widget.stock / widget.total;
    final bool hayStock = widget.stock > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.imagen, fit: BoxFit.contain),
                  // Gradiente inferior para que el contenido se lea
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.background, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Nombre y precio
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.descripcion,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),

                  const SizedBox(height: 16),

                  // Precio
                  Text(
                    "\$${widget.precio.toStringAsFixed(0)} MXN",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stock
                  _seccionTitulo("Disponibilidad"),
                  const SizedBox(height: 10),
                  _stockIndicador(porcentajeStock, hayStock),

                  const SizedBox(height: 24),

                  // Selector de acción
                  _seccionTitulo("¿Qué deseas hacer?"),
                  const SizedBox(height: 10),
                  _selectorAccion(),

                  const SizedBox(height: 24),

                  // Cantidad
                  _seccionTitulo("Cantidad"),
                  const SizedBox(height: 10),
                  _selectorCantidad(),

                  const SizedBox(height: 28),

                  // Resumen
                  _resumenPrecio(),

                  const SizedBox(height: 20),

                  // Botón principal
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: hayStock ? () => _mostrarConfirmacion(context) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _colorAccion(),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(_iconoAccion(), size: 18),
                      label: Text(
                        _textoBoton(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),

                  if (!hayStock)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Center(
                        child: Text(
                          "Producto sin stock disponible",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // STOCK INDICADOR
  // ================================

  Widget _stockIndicador(double porcentaje, bool hayStock) {
    final Color colorStock = porcentaje > 0.5
        ? const Color(0xFF22C55E)
        : porcentaje > 0.2
        ? const Color(0xFFFFA726)
        : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hayStock ? "${widget.stock} piezas disponibles" : "Sin stock",
                style: TextStyle(
                  color: colorStock,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                "${widget.stock} / ${widget.total}",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: porcentaje,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(colorStock),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // SELECTOR DE ACCIÓN
  // ================================

  Widget _selectorAccion() {
    return Row(
      children: [
        _chipAccion("comprar", "Comprar", Icons.shopping_bag_outlined),
        const SizedBox(width: 10),
        _chipAccion("apartar", "Apartar", Icons.bookmark_outline),
        const SizedBox(width: 10),
        _chipAccion("reservar", "Reservar", Icons.calendar_today_outlined),
      ],
    );
  }

  Widget _chipAccion(String valor, String texto, IconData icon) {
    final bool activo = _accionSeleccionada == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _accionSeleccionada = valor),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? _colorAccion().withOpacity(0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activo ? _colorAccion() : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: activo ? _colorAccion() : AppColors.textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(
                texto,
                style: TextStyle(
                  color: activo ? _colorAccion() : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================
  // SELECTOR DE CANTIDAD
  // ================================

  Widget _selectorCantidad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Unidades", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Row(
            children: [
              _botonCantidad(Icons.remove, () {
                if (_cantidad > 1) setState(() => _cantidad--);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  "$_cantidad",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _botonCantidad(Icons.add, () {
                if (_cantidad < widget.stock) setState(() => _cantidad++);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonCantidad(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }

  // ================================
  // RESUMEN DE PRECIO
  // ================================

  Widget _resumenPrecio() {
    final double total = widget.precio * _cantidad;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _filaResumen("Precio unitario", "\$${widget.precio.toStringAsFixed(0)} MXN"),
          const SizedBox(height: 8),
          _filaResumen("Cantidad", "$_cantidad unidad${_cantidad > 1 ? 'es' : ''}"),
          Divider(color: Colors.white.withOpacity(0.1), height: 20),
          _filaResumen("Total", "\$${total.toStringAsFixed(0)} MXN", destacado: true),
        ],
      ),
    );
  }

  Widget _filaResumen(String label, String valor, {bool destacado = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(
          valor,
          style: TextStyle(
            color: destacado ? AppColors.primary : AppColors.textPrimary,
            fontSize: destacado ? 17 : 14,
            fontWeight: destacado ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ================================
  // CONFIRMACIÓN
  // ================================

  void _mostrarConfirmacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Icon(_iconoAccion(), color: _colorAccion(), size: 40),
            const SizedBox(height: 12),
            Text(
              _textoConfirmacion(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "$_cantidad x ${widget.nombre}",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: _colorAccion(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Cancelar", style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // HELPERS
  // ================================

  Widget _seccionTitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _colorAccion() {
    switch (_accionSeleccionada) {
      case "apartar":  return const Color(0xFFFFA726);
      case "reservar": return AppColors.primary;
      default:         return AppColors.blue;
    }
  }

  IconData _iconoAccion() {
    switch (_accionSeleccionada) {
      case "apartar":  return Icons.bookmark_rounded;
      case "reservar": return Icons.calendar_today_rounded;
      default:         return Icons.shopping_bag_rounded;
    }
  }

  String _textoBoton() {
    switch (_accionSeleccionada) {
      case "apartar":  return "Apartar producto";
      case "reservar": return "Reservar producto";
      default:         return "Comprar ahora";
    }
  }

  String _textoConfirmacion() {
    switch (_accionSeleccionada) {
      case "apartar":  return "¿Deseas apartar este producto?";
      case "reservar": return "¿Deseas reservar este producto?";
      default:         return "¿Confirmas tu compra?";
    }
  }
}