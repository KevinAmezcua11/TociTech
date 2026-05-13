import 'package:flutter/material.dart';
import 'package:tocitech/ui/pages/services/servicios_page.dart';
import '../../../database/local/cart_local_service.dart';
import '../../../models/product_model.dart';
import '../../../models/service_model.dart';
import '../../../services/api_service.dart';
import '../../../services/home_summary_service.dart';
import '../../../services/product_service.dart';
import '../../../services/service_service.dart';
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
  bool _homeLoading = true;
  String? _homeError;
  HomeSummary? _homeSummary;
  List<ServiceModel> _featuredServices = [];
  List<Product> _availableProducts = [];

  late final HomeSummaryService _homeSummaryService;
  late final ServiceService _serviceService;
  late final ProductService _productService;

  final List _titulosAppBar = ["Inicio", "Productos", "Servicios", "Perfil"];

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _homeSummaryService = HomeSummaryService(api);
    _serviceService = ServiceService(api);
    _productService = ProductService(api);
    _loadCartCount();
    _loadHomeData();
  }

  Future<void> _loadCartCount() async {
    final count = await CartLocalService.getCartItemCount();
    if (mounted) setState(() => _cartCount = count);
  }

  Future<void> _loadHomeData() async {
    if (mounted) {
      setState(() {
        _homeLoading = true;
        _homeError = null;
      });
    }

    try {
      final results = await Future.wait([
        _homeSummaryService.getSummary(),
        _serviceService.getServices(),
        _productService.getProducts(),
      ]);

      final summary = results[0] as HomeSummary;
      final services = (results[1] as List<ServiceModel>)
          .where((service) => service.isActive)
          .toList();
      final products = (results[2] as List<Product>)
          .where((product) => product.isAvailable)
          .toList();

      if (!mounted) return;

      setState(() {
        _homeSummary = summary.copyWith(
          services: summary.services > 0 ? summary.services : services.length,
          products: summary.products > 0 ? summary.products : products.length,
        );
        _featuredServices = services.take(3).toList();
        _availableProducts = products;
      });
    } catch (e) {
      try {
        final results = await Future.wait([
          _serviceService.getServices(),
          _productService.getProducts(),
        ]);

        final services = (results[0] as List<ServiceModel>)
            .where((service) => service.isActive)
            .toList();
        final products = (results[1] as List<Product>)
            .where((product) => product.isAvailable)
            .toList();

        if (!mounted) return;

        setState(() {
          _homeSummary = HomeSummary(
            clients: _homeSummary?.clients ?? 0,
            services: services.length,
            products: products.length,
          );
          _featuredServices = services.take(3).toList();
          _availableProducts = products;
          _homeError =
              'Mostrando datos disponibles. No se pudo actualizar el resumen completo.';
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _homeError =
              'No pudimos actualizar el Home. Revisa tu conexion e intenta de nuevo.';
        });
      }
    } finally {
      if (mounted) setState(() => _homeLoading = false);
    }
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
            margin: const EdgeInsets.only(right: 6),
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificacionesPage()),
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
                margin: const EdgeInsets.only(right: 6),
                child: IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                    _loadCartCount();
                  },
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _cartCount > 99 ? '99+' : '$_cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
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
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (x) {
            setState(() => _index = x);
            if (x == 0) _loadHomeData();
          },
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
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _loadHomeData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _searchBar(),
          const SizedBox(height: 20),
          _heroSection(),
          if (_homeError != null) ...[
            const SizedBox(height: 18),
            _inlineHomeNotice(_homeError!),
          ],
          const SizedBox(height: 28),
          _estadisticasSection(),
          const SizedBox(height: 34),
          _sectionTitle(
            "Servicios destacados",
            "Opciones reales disponibles en el catalogo",
          ),
          const SizedBox(height: 18),
          _serviciosHorizontal(),
          const SizedBox(height: 34),
          _sectionTitle(
            "Catalogo activo",
            "Datos sincronizados con la informacion actual",
          ),
          const SizedBox(height: 18),
          _catalogSummarySection(),
          const SizedBox(height: 34),
          _sectionTitle("Horarios", "Estamos listos para ayudarte"),
          const SizedBox(height: 18),
          _horariosSection(),
        ],
      ),
    );
  }

  Widget _inlineHomeNotice(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Reintentar',
              onPressed: _loadHomeData,
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
          colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.asset(
                  "assets/Logo-img.png",
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "TociTech",
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
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => setState(() => _index = 1),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  iconAlignment: IconAlignment.start,
                  icon: const Icon(Icons.devices_rounded, size: 18),
                  label: const Text("Productos"),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _index = 2),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  iconAlignment: IconAlignment.start,
                  icon: const Icon(Icons.build_rounded, size: 18),
                  label: const Text("Servicios"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estadisticasSection() {
    final summary = _homeSummary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _statCard(
                Icons.people_alt_rounded,
                _homeLoading ? '...' : _formatCount(summary?.clients ?? 0),
                "Clientes",
                AppColors.primary,
              ),
              const SizedBox(width: 12),
              _statCard(
                Icons.build_circle_rounded,
                _homeLoading ? '...' : _formatCount(summary?.services ?? 0),
                "Servicios",
                AppColors.blue,
              ),
              const SizedBox(width: 12),
              _statCard(
                Icons.inventory_2_outlined,
                _homeLoading ? '...' : _formatCount(summary?.products ?? 0),
                "Productos",
                AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _syncStatusCard(),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _syncStatusCard() {
    final message = _homeLoading
        ? 'Actualizando informacion desde Firebase...'
        : 'Metricas cargadas desde la base de datos y servicios activos.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_done_outlined,
              color: AppColors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _serviciosHorizontal() {
    if (_homeLoading && _featuredServices.isEmpty) {
      return SizedBox(
        height: 178,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) => const _ServiceSkeletonCard(),
        ),
      );
    }

    if (_featuredServices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _HomeEmptyState(
          icon: Icons.handyman_outlined,
          title: 'Sin servicios activos',
          message:
              'Cuando agregues servicios desde el panel admin apareceran aqui.',
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _featuredServices.length,
        separatorBuilder: (context, index) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final s = _featuredServices[index];

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

  Widget _catalogSummarySection() {
    if (_homeLoading &&
        _availableProducts.isEmpty &&
        _featuredServices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _CatalogPulseCard(),
      );
    }

    final services = _featuredServices.length;
    final products = _availableProducts.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _CatalogInfoCard(
              icon: Icons.handyman_rounded,
              color: AppColors.blue,
              title: '$services destacado${services == 1 ? '' : 's'}',
              subtitle: 'Servicios listos para solicitar',
              onTap: () => setState(() => _index = 2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _CatalogInfoCard(
              icon: Icons.shopping_bag_rounded,
              color: AppColors.green,
              title: '$products disponible${products == 1 ? '' : 's'}',
              subtitle: 'Productos con stock activo',
              onTap: () => setState(() => _index = 1),
            ),
          ),
        ],
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
          _scheduleTile(Icons.weekend_rounded, "Sábados", "9:00 AM - 2:00 PM"),
          const SizedBox(height: 14),
          _scheduleTile(Icons.nights_stay_rounded, "Domingos", "Cerrado"),
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
              color: AppColors.primary.withValues(alpha: 0.12),
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
                Text(time, style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000) {
      final compact = (value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1);
      return '${compact}k';
    }

    return value.toString();
  }
}

class _ServiceSkeletonCard extends StatelessWidget {
  const _ServiceSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pulseBlock(height: 82, radius: 14),
          const SizedBox(height: 14),
          _pulseBlock(width: 180, height: 14),
          const SizedBox(height: 10),
          _pulseBlock(width: 220, height: 10),
          const SizedBox(height: 8),
          _pulseBlock(width: 120, height: 10),
        ],
      ),
    );
  }

  Widget _pulseBlock({
    double? width,
    required double height,
    double radius = 10,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _HomeEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogPulseCard extends StatelessWidget {
  const _CatalogPulseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _CatalogInfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CatalogInfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 132),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
