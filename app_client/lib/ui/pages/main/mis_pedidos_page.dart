import 'dart:async';
import 'package:flutter/material.dart';
import '../../../controllers/order_controller.dart';
import '../../../models/order_model.dart';
import '../../../services/api_service.dart';
import '../../../services/order_service.dart';
import '../../../theme/app_theme.dart';
import '../../pages/main/home_page.dart';

class MisPedidosPage extends StatefulWidget {
  const MisPedidosPage({super.key});

  @override
  State<MisPedidosPage> createState() => _MisPedidosPageState();
}

class _MisPedidosPageState extends State<MisPedidosPage>
    with SingleTickerProviderStateMixin {
  late final OrderController _controller;
  late final TabController _tabController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = OrderController(OrderService(ApiService()));
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchOrders());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    await _controller.fetchOrders();
    if (mounted) setState(() {});
  }

  List<Order> get _productOrders =>
      _controller.orders.where((o) => o.type == 'product').toList();

  List<Order> get _serviceOrders =>
      _controller.orders.where((o) => o.type == 'service').toList();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const TociTechApp(),
          ),
              (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text(
            'Mis Pedidos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text('Productos (${_productOrders.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.handyman_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text('Servicios (${_serviceOrders.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: _controller.isLoading && _controller.orders.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _controller.errorMessage != null && _controller.orders.isEmpty
                ? _errorView()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _OrderList(orders: _productOrders),
                      _OrderList(orders: _serviceOrders),
                    ],
                  ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 52, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage ?? 'Error al cargar pedidos',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _fetchOrders,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 52,
                color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text('Sin pedidos',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, idx) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.type == 'product'
                      ? _productTitle()
                      : (order.service?.name ?? 'Servicio'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _PedidoBadge(estadoPedido: order.estadoPedido),
            ],
          ),
          if (order.type == 'service' && order.equipment != null) ...[
            const SizedBox(height: 4),
            Text(
              order.equipment!,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (order.createdAt != null)
                Text(
                  _formatDate(order.createdAt!),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              const Spacer(),
              if (order.estadoPago != null)
                _PaymentBadge(estadoPago: order.estadoPago!),
              if (order.total != null) ...[
                const SizedBox(width: 8),
                Text(
                  '\$${order.total!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          if (order.type == 'product' && order.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 8),
            ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${item.quantity}x ${item.name}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            if (order.items.length > 2)
              Text(
                '+ ${order.items.length - 2} más',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11),
              ),
          ],
        ],
      ),
    );
  }

  String _productTitle() {
    if (order.items.isEmpty) return 'Pedido de productos';
    if (order.items.length == 1) return order.items.first.name;
    return '${order.items.first.name} y ${order.items.length - 1} más';
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class _PedidoBadge extends StatelessWidget {
  final String estadoPedido;

  const _PedidoBadge({required this.estadoPedido});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (estadoPedido) {
      'EN_PROGRESO' => (const Color(0xFF3B82F6), 'En progreso'),
      'COMPLETADO' => (const Color(0xFF22C55E), 'Completado'),
      'CANCELADO' => (Colors.redAccent, 'Cancelado'),
      _ => (const Color(0xFFFFA726), 'Pendiente'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String estadoPago;

  const _PaymentBadge({required this.estadoPago});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (estadoPago) {
      'PAGADO' => (const Color(0xFF22C55E), 'Pagado'),
      'FALLIDO' => (Colors.redAccent, 'Fallido'),
      'REEMBOLSADO' => (const Color(0xFF8B5CF6), 'Reembolsado'),
      _ => (const Color(0xFFFFA726), 'Pend. pago'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
