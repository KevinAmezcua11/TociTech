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
import '../../widgets/product_card.dart';
import '../../widgets/service_card.dart';
import '../cart/cart_page.dart';
import '../products/product_detail_page.dart';
import '../services/service_detail_page.dart';
import 'ajustes_page.dart';
import 'notificaciones_page.dart';
import '../products/products_page.dart';
import 'busqueda_page.dart';


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
  List<Product> _featuredProducts = [];
  List<ServiceModel> _featuredServices = [];

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
        _featuredProducts = products.take(3).toList();
        _featuredServices = services.take(3).toList();
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
          _featuredProducts = products.take(3).toList();
          _featuredServices = services.take(3).toList();
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
        padding: const EdgeInsets.only(bottom: 24),
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
            "Productos destacados",
            "Los mejores productos disponibles ahora",
          ),
          const SizedBox(height: 18),
          _productosHorizontal(),
          const SizedBox(height: 34),
          _sectionTitle(
            "Servicios destacados",
            "Los servicios más solicitados por nuestros clientes",
          ),
          const SizedBox(height: 18),
          _serviciosHorizontal(),
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
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.07),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _productosHorizontal() {
    if (_homeLoading && _featuredProducts.isEmpty) {
      return SizedBox(
        height: 310,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, _) => const _ProductSkeletonCard(),
        ),
      );
    }

    if (_featuredProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _HomeEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Sin productos disponibles',
          message: 'Cuando agregues productos desde el panel admin apareceran aqui.',
        ),
      );
    }

    return SizedBox(
      height: 310,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _featuredProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final p = _featuredProducts[index];
          return SizedBox(
            width: 160,
            height: 310,
            child: ProductCard(
              product: p,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: p),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _serviciosHorizontal() {
    if (_homeLoading && _featuredServices.isEmpty) {
      return SizedBox(
        height: 310,
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
      height: 310,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _featuredServices.length,
        separatorBuilder: (context, index) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final s = _featuredServices[index];

          return SizedBox(
            width: 260,
            child: Align(
              alignment: Alignment.topLeft,
              child: ServiceCard(
                service: s,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailPage(service: s),
                  ),
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
            AppColors.primary,
          ),
          const SizedBox(height: 14),
          _scheduleTile(Icons.weekend_rounded, "Sábados", "9:00 AM - 2:00 PM", AppColors.green),
          const SizedBox(height: 14),
          _scheduleTile(Icons.nights_stay_rounded, "Domingos", "Cerrado", Colors.orange),
        ],
      ),
    );
  }

  Widget _scheduleTile(IconData icon, String title, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
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

class _ProductSkeletonCard extends StatelessWidget {
  const _ProductSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 310,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(height: 150, radius: 22, bottomRadius: 0),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(height: 14),
                const SizedBox(height: 6),
                _block(width: 90, height: 10),
                const SizedBox(height: 14),
                _block(width: 80, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _block({double? width, required double height, double radius = 10, double bottomRadius = 10}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radius),
          bottom: Radius.circular(bottomRadius),
        ),
      ),
    );
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

