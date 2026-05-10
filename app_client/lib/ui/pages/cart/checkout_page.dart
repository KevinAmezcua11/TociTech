import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../services/api_service.dart';
import '../../../services/payment_service.dart';
import '../../../database/local/cart_local_service.dart';
import '../../../theme/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> paymentItems;
  final double total;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.paymentItems,
    required this.total,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _loading = false;
  bool _success = false;
  String? _error;

  Future<void> _pay() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final svc = PaymentService(ApiService());
      final result = await svc.createPaymentIntent(widget.paymentItems);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: result['clientSecret']!,
          merchantDisplayName: 'TociTech',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6C63FF),
              background: Color(0xFF0F0F14),
              componentBackground: Color(0xFF1A1A22),
              primaryText: Colors.white,
              secondaryText: Color(0xFFB0B0C0),
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await CartLocalService.clearCart();

      if (mounted) setState(() => _success = true);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // user dismissed the sheet — no error to show
        if (mounted) setState(() => _loading = false);
      } else {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = e.error.localizedMessage ?? 'Error al procesar el pago';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _successView();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Confirmar pago',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Resumen del pedido'),
          const SizedBox(height: 10),
          ...widget.items.map((item) {
            final price = (item['product_price'] as num).toDouble();
            final qty = item['quantity'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['product_name'] as String? ?? '',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'x$qty · \$${price.toStringAsFixed(2)} c/u',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(price * qty).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total a pagar',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text(
                  '\$${widget.total.toStringAsFixed(2)} MXN',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _sectionHeader('Método de pago'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.credit_card_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pago seguro con Stripe',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text('Tarjeta de crédito / débito',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.lock_outline_rounded,
                    color: AppColors.textMuted, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: _loading ? null : _pay,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.lock_rounded, size: 18),
            label: Text(
              _loading
                  ? 'Procesando...'
                  : 'Pagar \$${widget.total.toStringAsFixed(2)} MXN',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _successView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.green, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Pago exitoso!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu pedido ha sido recibido y está en proceso.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Ver mis pedidos',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );
}
