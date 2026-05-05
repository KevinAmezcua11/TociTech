import 'package:flutter/material.dart';
import '../services/service_detail_page.dart';
import '../../../theme/app_theme.dart';

class _Servicio {
  final String titulo;
  final String descripcion;
  final String imagen;
  final int precio;
  final String tiempo;
  final IconData icono;

  const _Servicio({
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.precio,
    required this.tiempo,
    required this.icono,
  });
}

class ServiciosPage extends StatelessWidget {
  const ServiciosPage({super.key});

  static const List<_Servicio> _servicios = [
    _Servicio(
      titulo: "Diagnóstico técnico",
      descripcion: "Revisión completa para detectar fallas de hardware o software.",
      imagen: "assets/servicio1.png",
      precio: 150,
      tiempo: "1-2",
      icono: Icons.search_rounded,
    ),
    _Servicio(
      titulo: "Mantenimiento Preventivo",
      descripcion: "Limpieza y optimización para prolongar la vida útil del equipo.",
      imagen: "assets/servicio2.png",
      precio: 350,
      tiempo: "1",
      icono: Icons.cleaning_services_rounded,
    ),
    _Servicio(
      titulo: "Reparación de Hardware",
      descripcion: "Solución de fallas físicas en laptop o PC.",
      imagen: "assets/servicio3.png",
      precio: 400,
      tiempo: "1-15",
      icono: Icons.handyman_rounded,
    ),
    _Servicio(
      titulo: "Instalación de Software",
      descripcion: "Instalación de sistemas operativos, drivers y programas.",
      imagen: "assets/instalacionSoftware.jpg",
      precio: 200,
      tiempo: "1",
      icono: Icons.install_desktop_rounded,
    ),
    _Servicio(
      titulo: "Recuperación de Datos",
      descripcion: "Recuperación de archivos perdidos por falla o formateo accidental.",
      imagen: "assets/recuperacionDatos.jpg",
      precio: 500,
      tiempo: "2-5",
      icono: Icons.restore_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 40),
        itemCount: _servicios.length + 1,
        separatorBuilder: (_, index) =>
        index == 0 ? const SizedBox(height: 20) : const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ServiceCard(servicio: _servicios[index - 1]),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Nuestros Servicios",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Soluciones técnicas con precios claros y accesibles.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _Servicio servicio;

  const _ServiceCard({required this.servicio});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailPage(
                titulo: servicio.titulo,
                descripcion: servicio.descripcion,
                imagen: servicio.imagen,
                precio: servicio.precio,
                tiempo: servicio.tiempo,
                icono: servicio.icono,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
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
                    child: Image.asset(servicio.imagen, fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00E676).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_money_rounded,
                              color: Color(0xFF00E676), size: 13),
                          Text(
                            "Desde \$${servicio.precio} MXN",
                            style: const TextStyle(
                              color: Color(0xFF00E676),
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
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(servicio.icono,
                              color: AppColors.primary, size: 16),
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
                            color: AppColors.blue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(Icons.schedule_rounded,
                              color: AppColors.blue, size: 13),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${servicio.tiempo} días hábiles",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
