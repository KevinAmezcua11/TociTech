import 'package:flutter/material.dart';
import 'package:tocitech/pages/login_page.dart';
import 'package:tocitech/services/firebase_bootstrap.dart';
import 'package:tocitech/services/settings_preferences.dart';
import 'package:tocitech/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settingsController.load();
  await FirebaseBootstrap.initialize();

  runApp(const TociTechClientApp());
}

class TociTechClientApp extends StatelessWidget {
  const TociTechClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ClientSettings>(
      valueListenable: settingsController,
      builder: (context, settings, _) {
        final isLight = settings.themeMode == ClientThemeMode.light;

        return MaterialApp(
          home: const LoginPage(),
          debugShowCheckedModeBanner: false,
          themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
          theme: ThemeData(
            brightness: isLight ? Brightness.light : Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: isLight ? Brightness.light : Brightness.dark,
            ),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}
