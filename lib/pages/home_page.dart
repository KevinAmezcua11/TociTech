import 'package:flutter/material.dart';
import 'package:tocitech/pages/servicios_page.dart';
import '../theme/app_theme.dart';
import '../widgets/service_card.dart';
import 'ajustes_page.dart';
import 'notificaciones_page.dart';
import 'products_page.dart';
import 'busqueda_page.dart';
import 'ai_chat_page.dart';

class TociTechApp extends StatefulWidget {
  const TociTechApp({super.key});

  @override
  State<TociTechApp> createState() => _TociTechAppState();
}

class _TociTechAppState extends State<TociTechApp> {
  int _index = 0;

  final List _titulosAppBar = [
    "TociTech",
    "Productos",
    "Servicios",
    "Ajustes"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        toolbarHeight: 70,
        title: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            _titulosAppBar[_index],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificacionesPage()),
            ),
            icon: Icon(Icons.notifications_outlined, color: AppColors.primary),
          ),
        ],
      ),

      body: _contenido(),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Container(
          padding: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (x) => setState(() => _index = x),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Inicio"),
              BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: "Productos"),
              BottomNavigationBarItem(icon: Icon(Icons.handyman), label: "Servicios"),
              BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Ajustes"),
            ],
            iconSize: 24,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showUnselectedLabels: true,
            selectedIconTheme: IconThemeData(color: AppColors.primary),
            unselectedIconTheme: IconThemeData(color: Color(0xFF8A8A93)),
            selectedLabelStyle: TextStyle(fontSize: 12),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Color(0xFFD6D6D6),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,MaterialPageRoute(builder: (_) => const AiChatPage()),
        ),
        backgroundColor: AppColors.blue,
        child: Icon(Icons.smart_toy, size: 28, color: Colors.white),
      ),
    );
  }

  Widget? _contenido() {
    switch (_index) {
      case 0:  return _buildHome();
      case 1:  return const ProductsPage();
      case 2:  return const ServiciosPage();
      case 3:  return const AjustesPage();
      default: return const Center(child: Text("Página no existe"));
    }
  }

  Widget _buildHome() {
    return ListView(
      children: [
        _searchBar(),
        SizedBox(height: 1),
        _heroSection(),
        SizedBox(height: 28),
        _estadisticasSection(),
        SizedBox(height: 32),
        _seccionTitulo("Nuestros Servicios", "Soluciones con precios claros y accesibles"),
        SizedBox(height: 16),
        _serviciosHorizontal(),
        SizedBox(height: 32),
        _seccionTitulo("Horarios de Atención", "Disponibles para ayudarte"),
        SizedBox(height: 16),
        _horariosSection(),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BusquedaPage()),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Color(0xFF8A8A93), size: 20),
              SizedBox(width: 10),
              Text("Buscar producto...",
                  style: TextStyle(color: Color(0xFF8A8A93), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Image.asset("assets/Logo-img.png"),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TociTech",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text("Soluciones tecnológicas\npara tu equipo",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14),

          Text("Venta de hardware, reparación especializada y atención para que tu equipo rinda al máximo.",
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5
            ),
          ),

          SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => setState(() => _index = 1),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.grid_view_rounded, size: 16),
                  label: Text("Ver productos",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13
                      )
                  ),
                ),
              ),

              SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _index = 2),
                  icon: Icon(Icons.handyman_rounded, size: 16, color: Colors.black87),
                  label: Text("Ver servicios",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 13
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estadisticasSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard(Icons.star_rounded, "4.9", "Calificación", Color(0xFFFFD54F)),
          SizedBox(width: 12),
          _statCard(Icons.people_rounded, "500+", "Clientes", AppColors.primary),
          SizedBox(width: 12),
          _statCard(Icons.build_circle_rounded, "1000+", "Reparaciones", AppColors.blue),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String titulo, String descripcion, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(height: 6),
            Text(titulo,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
              ),
            ),
            SizedBox(height: 2),
            Text(descripcion,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionTitulo(String titulo, String subtitulo) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(subtitulo,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Seccion Servicios
  Widget _serviciosHorizontal() {
    final servicios = [
      {
        "titulo": "Diagnóstico técnico",
        "descripcion": "Revisión completa para detectar fallas de hardware o software.",
        "imagen": "assets/servicio1.png",
        "precio": 150,
        "tiempo": "1-2",
      },
      {
        "titulo": "Mantenimiento Preventivo",
        "descripcion": "Limpieza y optimización para prolongar la vida útil del equipo.",
        "imagen": "assets/servicio2.png",
        "precio": 350,
        "tiempo": "1",
      },
      {
        "titulo": "Reparación de Hardware",
        "descripcion": "Solución de fallas físicas en laptop o PC.",
        "imagen": "assets/servicio3.png",
        "precio": 400,
        "tiempo": "1-15",
      },
    ];

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: servicios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final s = servicios[i];
          return SizedBox(
            width: 240,
            child: ServiceCard(
              titulo: s["titulo"] as String,
              descripcion: s["descripcion"] as String,
              imagen: s["imagen"] as String,
              precio: s["precio"] as int,
              tiempo: s["tiempo"] as String,
              textoBoton: "Solicitar",
            ),
          );
        },
      ),
    );
  }

  // Seccion Horarios
  Widget _horariosSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _horarioRow(Icons.wb_sunny_outlined, "Lunes a Viernes", "9:00 AM – 7:00 PM", AppColors.primary),
          SizedBox(height: 10),
          _horarioRow(Icons.wb_twilight_outlined, "Sábado", "9:00 AM – 2:00 PM", AppColors.blue),
          SizedBox(height: 10),
          _horarioRow(Icons.bedtime_outlined, "Domingo", "Cerrado", Colors.grey),
        ],
      ),
    );
  }

  Widget _horarioRow(IconData icon, String dia, String horario, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Text(dia,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14
              ),
            ),
          ),

          Text(horario,
            style: TextStyle(
              color: horario == "Cerrado" ? Colors.grey : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}