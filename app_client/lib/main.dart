import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tocitech/ui/pages/auth/login_page.dart';

const _stripePublishableKey = 'pk_test_51TVL7nRziKh0MZWDt7kvGTAXAGIGMD1ZZP9zEF1YCaXVFIzh3bKF6A5RyDMkey79BprTwF2yEHIXbEo0Px5pj8mi00JmD392mM';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = _stripePublishableKey;
  runApp(const MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}
