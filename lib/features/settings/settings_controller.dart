import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/native_channel.dart';
import '../../core/models/app_settings.dart';
import '../../core/platform/native_bridge.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs, this._bridge);

  static const _key = 'settings_v1';
  final SharedPreferences _prefs;
  final NativeBridge _bridge;

  AppSettings _settings = const AppSettings();
  AppSettings get value => _settings;

  Future<void> load() async {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        _settings = AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _settings = const AppSettings();
      }
    }
    notifyListeners();
    await save();
  }

  /// Updates the UI only (used while a slider is being dragged).
  void preview(AppSettings s) {
    _settings = s;
    notifyListeners();
  }

  /// Persists locally and pushes to Android so alarms use the latest values.
  Future<void> save() async {
    final json = jsonEncode(_settings.toJson());
    await _prefs.setString(_key, json);
    try {
      await _bridge.call<bool>(NativeChannel.saveSettings, {'json': json});
    } on PlatformException {
      // Native copy will be refreshed on next launch.
    } on MissingPluginException {
      // Not running on Android.
    }
  }

  Future<void> update(AppSettings s) {
    preview(s);
    return save();
  }
}
