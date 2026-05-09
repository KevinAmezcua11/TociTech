import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class _Pedido {
  final String nombre;
  final String imagen;
  final String fecha;
  final String estado;

  const _Pedido({
    required this.nombre,
    required this.imagen,
    required this.fecha,
    required this.estado,
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

class MisPedidosPage extends StatelessWidget {
  const MisPedidosPage({super.key});

  static const List<_Pedido> _pedidos = [
    _Pedido(
      nombre: "Memoria RAM Kingston Fury 16GB",
      imagen: "assets/img-1.png",
      fecha: "10 Abr 2026",
      estado: "completado",
    ),
    _Pedido(
      nombre: "NVIDIA GeForce RTX 3060 12GB",
      imagen: "assets/img-3.png",
      fecha: "08 Abr 2026",
      estado: "pendiente",
    ),
    _Pedido(
      nombre: "Procesador AMD Ryzen 5 5600G",
      imagen: "assets/img-2.png",
      fecha: "05 Abr 2026",
      estado: "pendiente",
    ),
    _Pedido(
      nombre: "Corsair Vengeance 16GB DDR4",
      imagen: "assets/img-4.jpg",
      fecha: "01 Abr 2026",
      estado: "cancelado",
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            _pedidos.isEmpty
                ? _estadoVacio()
                : Column(
              children: _pedidos
                  .map((p) => Padding(
                padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _PedidoCard(pedido: p),
              ))
                  .toList(),
            ),

            const SizedBox(height: 28),

            _seccionServicios(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _estadoVacio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 52,
              color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text(
            "Sin pedidos",
            style:
            TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _seccionServicios() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Servicios Solicitados",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${_servicios.length}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

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
                ),
                const SizedBox(height: 5),
                Text(
                  pedido.fecha,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 7),
                _badgeEstado(pedido.estado),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeEstado(String estado) {
    Color color;
    String texto;

    switch (estado) {
      case "completado":
        color = const Color(0xFF22C55E);
        texto = "Completado";
        break;
      case "cancelado":
        color = Colors.redAccent;
        texto = "Cancelado";
        break;
      default:
        color = const Color(0xFFFFA726);
        texto = "Pendiente";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

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
                ),
                const SizedBox(height: 4),
                Text(
                  servicio.equipo,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  servicio.fecha,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    servicio.estado,
                    style: TextStyle(
                      color: colorEstado,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
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