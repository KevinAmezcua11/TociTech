import 'package:flutter/material.dart';
import 'package:tocitech/ui/pages/services/servicios_page.dart';
import '../../../database/local/cart_local_service.dart';
import '../../../models/service_model.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/service_card.dart';
import '../cart/cart_page.dart';
import '../services/service_detail_page.dart';
import 'ajustes_page.dart';
import 'notificaciones_page.dart';
import '../products/products_page.dart';
import 'busqueda_page.dart';
import '../ai/ai_chat_page.dart';

class TociTechApp extends StatefulWidget {
  const TociTechApp({super.key});

  @override
  State<TociTechApp> createState() => _TociTechAppState();
}

class _TociTechAppState extends State<TociTechApp> {
  int _index = 0;
  int _cartCount = 0;

  final List _titulosAppBar = [
    "Inicio",
    "Productos",
    "Servicios",
    "Perfil"
  ];

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final count = await CartLocalService.getCartItemCount();
    if (mounted) setState(() => _cartCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenido",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              _titulosAppBar[_index],
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificacionesPage(),
                ),
              ),
              icon: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                    _loadCartCount();
                  },
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 16,
                  top: 2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _cartCount > 99 ? '99+' : '$_cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _contenido(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        elevation: 10,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatPage()),
        ),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (x) => setState(() => _index = x),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white54,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Inicio",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded),
              label: "Productos",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman_rounded),
              label: "Servicios",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Perfil",
            ),
          ],
        ),
      ),
    );
  }

  Widget? _contenido() {
    switch (_index) {
      case 0:
        return _buildHome();
      case 1:
        return const ProductsPage();
      case 2:
        return const ServiciosPage();
      case 3:
        return const AjustesPage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildHome() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        _searchBar(),
        const SizedBox(height: 20),
        _heroSection(),
        const SizedBox(height: 28),
        _estadisticasSection(),
        const SizedBox(height: 34),
        _sectionTitle(
          "Servicios Destacados",
          "Soluciones rápidas para tus dispositivos",
        ),
        const SizedBox(height: 18),
        _serviciosHorizontal(),
        const SizedBox(height: 34),
        _sectionTitle(
          "Horarios",
          "Estamos listos para ayudarte",
        ),
        const SizedBox(height: 18),
        _horariosSection(),
      ],
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BusquedaPage()),
        ),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                "Buscar productos o servicios",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.memory_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "TOP TECH",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            "Tecnología y reparación profesional",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Productos, reparación y soporte técnico en un solo lugar.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => setState(() => _index = 1),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text("Explorar productos"),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _index = 2),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Servicios",
                    style: TextStyle(color: Colors.white),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard(Icons.star_rounded, "4.9", "Calificación"),
          const SizedBox(width: 14),
          _statCard(Icons.people_alt_rounded, "500+", "Clientes"),
          const SizedBox(width: 14),
          _statCard(Icons.build_circle_rounded, "1000+", "Servicios"),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviciosHorizontal() {
    final servicios = [
      ServiceModel(
        id: '',
        name: 'Diagnóstico Técnico',
        description: 'Revisión completa para detectar fallas.',
        price: 150,
        duration: '1 día',
        active: true,
      ),
      ServiceModel(
        id: '',
        name: 'Mantenimiento Preventivo',
        description: 'Optimización y limpieza profesional.',
        price: 350,
        duration: '1 día',
        active: true,
      ),
      ServiceModel(
        id: '',
        name: 'Reparación de Hardware',
        description: 'Solución de fallas físicas.',
        price: 450,
        duration: '2 días',
        active: true,
      ),
    ];

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: servicios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final s = servicios[index];

          return SizedBox(
            width: 260,
            child: ServiceCard(
              service: s,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceDetailPage(service: s),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _horariosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _scheduleTile(
            Icons.calendar_today_rounded,
            "Lunes a Viernes",
            "9:00 AM - 7:00 PM",
          ),
          const SizedBox(height: 14),
          _scheduleTile(
            Icons.weekend_rounded,
            "Sábados",
            "9:00 AM - 2:00 PM",
          ),
          const SizedBox(height: 14),
          _scheduleTile(
            Icons.nights_stay_rounded,
            "Domingos",
            "Cerrado",
          ),
        ],
      ),
    );
  }

  Widget _scheduleTile(IconData icon, String title, String time) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.textSecondary,
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