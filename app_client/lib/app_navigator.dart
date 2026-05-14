import 'package:flutter/material.dart';

/// Clave global del Navigator principal de la app.
/// Permite navegar desde callbacks que no tienen BuildContext (ej. onSessionExpired).
final appNavigatorKey = GlobalKey<NavigatorState>();
