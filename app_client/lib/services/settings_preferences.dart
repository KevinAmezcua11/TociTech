import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ClientThemeMode { dark, light }

class ClientSettings {
  final ClientThemeMode themeMode;
  final bool notificationsEnabled;

  const ClientSettings({
    required this.themeMode,
    required this.notificationsEnabled,
  });

  ClientSettings copyWith({
    ClientThemeMode? themeMode,
    bool? notificationsEnabled,
  }) {
    return ClientSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsController extends ValueNotifier<ClientSettings> {
  SettingsController()
      : super(
          const ClientSettings(
            themeMode: ClientThemeMode.dark,
            notificationsEnabled: true,
          ),
        );

  static const _themeKey = 'client_theme';
  static const _notificationsKey = 'client_notifications';

  SharedPreferences? _preferences;

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    final theme = _preferences?.getString(_themeKey);
    final notifications = _preferences?.getBool(_notificationsKey);

    value = ClientSettings(
      themeMode: theme == 'light' ? ClientThemeMode.light : ClientThemeMode.dark,
      notificationsEnabled: notifications ?? true,
    );
  }

  Future<void> setTheme(ClientThemeMode themeMode) async {
    value = value.copyWith(themeMode: themeMode);
    await _save();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    value = value.copyWith(notificationsEnabled: enabled);
    await _save();
  }

  Future<void> _save() async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    _preferences = preferences;

    await preferences.setString(
      _themeKey,
      value.themeMode == ClientThemeMode.light ? 'light' : 'dark',
    );
    await preferences.setBool(_notificationsKey, value.notificationsEnabled);
  }
}

final settingsController = SettingsController();
