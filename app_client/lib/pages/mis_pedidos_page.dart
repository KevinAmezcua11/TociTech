import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _Pedido {
  final String nombre;
  final String imagen;
  final String fecha;
  final String estado;
  final String tipo;

  const _Pedido({
    required this.nombre,
    required this.imagen,
    required this.fecha,
    required this.estado,
    required this.tipo,
  });
}

class _Servicio {
  final String nombre;
  final String imagen;
  final String fecha;
  final String estado;
  final String equipo;

  const _Servicio({
    required this.nombre,
    required this.imagen,
    required this.fecha,
    required this.estado,
    required this.equipo,
  });
}

class MisPedidosPage extends StatefulWidget {
  const MisPedidosPage({super.key});

  @override
  State<MisPedidosPage> createState() => _MisPedidosPageState();
}

class _MisPedidosPageState extends State<MisPedidosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<_Pedido> _todos = [
    _Pedido(
      nombre: "Memoria RAM Kingston Fury 16GB",
      imagen: "assets/img-1.png",
      fecha: "10 Abr 2026",
      estado: "completado",
      tipo: "compra",
    ),
    _Pedido(
      nombre: "NVIDIA GeForce RTX 3060 12GB",
      imagen: "assets/img-3.png",
      fecha: "08 Abr 2026",
      estado: "pendiente",
      tipo: "compra",
    ),
    _Pedido(
      nombre: "Procesador AMD Ryzen 5 5600G",
      imagen: "assets/img-2.png",
      fecha: "05 Abr 2026",
      estado: "pendiente",
      tipo: "apartado",
    ),
    _Pedido(
      nombre: "Corsair Vengeance 16GB DDR4",
      imagen: "assets/img-4.jpg",
      fecha: "01 Abr 2026",
      estado: "cancelado",
      tipo: "apartado",
    ),
    _Pedido(
      nombre: "Fuente Corsair 650W 80+ Bronze",
      imagen: "assets/img-5.png",
      fecha: "28 Mar 2026",
      estado: "pendiente",
      tipo: "reservacion",
    ),
    _Pedido(
      nombre: "Memoria RAM Kingston Fury 16GB",
      imagen: "assets/img-1.png",
      fecha: "20 Mar 2026",
      estado: "completado",
      tipo: "reservacion",
    ),
  ];

  static const List<_Servicio> _servicios = [
    _Servicio(
      nombre: "Diagnóstico técnico",
      imagen: "assets/servicio1.png",
      fecha: "09 Abr 2026",
      estado: "pendiente",
      equipo: "Laptop HP Pavilion 15",
    ),
    _Servicio(
      nombre: "Mantenimiento Preventivo",
      imagen: "assets/servicio2.png",
      fecha: "02 Abr 2026",
      estado: "completado",
      equipo: "PC de escritorio",
    ),
    _Servicio(
      nombre: "Reparación de Hardware",
      imagen: "assets/servicio3.png",
      fecha: "25 Mar 2026",
      estado: "cancelado",
      equipo: "MacBook Air M1",
    ),
  ];

  List<_Pedido> get _compras =>
      _todos.where((p) => p.tipo == "compra").toList();
  List<_Pedido> get _apartados =>
      _todos.where((p) => p.tipo == "apartado").toList();
  List<_Pedido> get _reservaciones =>
      _todos.where((p) => p.tipo == "reservacion").toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          "Mis Pedidos",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: [
            _buildTab("Compras", _compras.length),
            _buildTab("Apartados", _apartados.length),
            _buildTab("Reservaciones", _reservaciones.length),
          ],
        ),
      ),

      // Todo en un solo scroll vertical
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Contenido del tab seleccionado
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                List<_Pedido> pedidos;
                switch (_tabController.index) {
                  case 1:
                    pedidos = _apartados;
                    break;
                  case 2:
                    pedidos = _reservaciones;
                    break;
                  default:
                    pedidos = _compras;
                }
                return pedidos.isEmpty
                    ? _estadoVacio()
                    : Column(
                  children: pedidos
                      .map((p) => Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 0, 20, 12),
                    child: _PedidoCard(pedido: p),
                  ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 28),

            // Sección servicios justo debajo
            _seccionServicios(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Tab _buildTab(String texto, int cantidad) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(texto),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$cantidad",
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // ESTADO VACÍO
  // ================================

  Widget _estadoVacio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined,
                size: 52, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text(
              "Sin pedidos aquí",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // SECCIÓN SERVICIOS
  // ================================

  Widget _seccionServicios() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.handyman_rounded,
                        color: Color(0xFF22C55E), size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Servicios Solicitados",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${_servicios.length}",
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Lista vertical de servicios
          Column(
            children: _servicios
                .map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ServicioCard(servicio: s),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ================================
// CARD DE PEDIDO
// ================================

class _PedidoCard extends StatelessWidget {
  final _Pedido pedido;

  const _PedidoCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              pedido.imagen,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.nombre,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      pedido.fecha,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                _badgeEstado(pedido.estado),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _colorTipo(pedido.tipo).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconoTipo(pedido.tipo),
                color: _colorTipo(pedido.tipo), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _badgeEstado(String estado) {
    Color color;
    String texto;
    IconData icono;

    switch (estado) {
      case "completado":
        color = const Color(0xFF22C55E);
        texto = "Completado";
        icono = Icons.check_circle_outline;
        break;
      case "cancelado":
        color = Colors.redAccent;
        texto = "Cancelado";
        icono = Icons.cancel_outlined;
        break;
      default:
        color = const Color(0xFFFFA726);
        texto = "Pendiente";
        icono = Icons.access_time_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case "apartado":    return const Color(0xFFFFA726);
      case "reservacion": return AppColors.primary;
      default:            return AppColors.blue;
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case "apartado":    return Icons.bookmark_rounded;
      case "reservacion": return Icons.calendar_today_rounded;
      default:            return Icons.shopping_bag_rounded;
    }
  }
}

// ================================
// CARD DE SERVICIO
// ================================

class _ServicioCard extends StatelessWidget {
  final _Servicio servicio;

  const _ServicioCard({required this.servicio});

  @override
  Widget build(BuildContext context) {
    Color colorEstado;
    switch (servicio.estado) {
      case "completado":
        colorEstado = const Color(0xFF22C55E);
        break;
      case "cancelado":
        colorEstado = Colors.redAccent;
        break;
      default:
        colorEstado = const Color(0xFFFFA726);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              servicio.imagen,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  servicio.nombre,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.devices_outlined,
                        size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      servicio.equipo,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      servicio.fecha,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorEstado.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        servicio.estado == "completado"
                            ? Icons.check_circle_outline
                            : servicio.estado == "cancelado"
                            ? Icons.cancel_outlined
                            : Icons.access_time_rounded,
                        color: colorEstado,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        servicio.estado[0].toUpperCase() +
                            servicio.estado.substring(1),
                        style: TextStyle(
                            color: colorEstado,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.handyman_rounded,
                color: Color(0xFF22C55E), size: 18),
          ),
        ],
      ),
    );
  }
}