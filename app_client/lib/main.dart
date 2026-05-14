import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tocitech/app_navigator.dart';
import 'package:tocitech/services/auth_service.dart';
import 'package:tocitech/theme/app_theme.dart';
import 'package:tocitech/ui/pages/auth/login_page.dart';
import 'package:tocitech/ui/pages/main/home_page.dart';

const _stripePublishableKey =
    'pk_test_51TVL7nRziKh0MZWDt7kvGTAXAGIGMD1ZZP9zEF1YCaXVFIzh3bKF6A5RyDMkey79BprTwF2yEHIXbEo0Px5pj8mi00JmD392mM';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = _stripePublishableKey;
  runApp(MaterialApp(
    navigatorKey: appNavigatorKey,
    home: const _AppBootstrap(),
    debugShowCheckedModeBanner: false,
  ));
}

/// Muestra un loader mientras verifica si hay sesión guardada,
/// luego navega a Home o Login según corresponda.
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final authService = AuthService();
    final session = await authService.getSavedSession();

    // Registrar el callback usando navigatorKey para que funcione
    // incluso después de que el widget sea reemplazado.
    authService.api.onSessionExpired = () async {
      await authService.logout();
      appNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    };

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            session != null ? const TociTechApp() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
