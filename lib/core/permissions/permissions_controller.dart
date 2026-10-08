import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../constants/native_channel.dart';
import '../platform/native_bridge.dart';

/// Tracks the Android permissions/special access MiniMe depends on.
class PermissionsController extends ChangeNotifier {
  PermissionsController(this._bridge);

  final NativeBridge _bridge;

  bool overlayGranted = false;
  bool exactAlarmAllowed = false;
  bool notificationsGranted = false;

  Future<void> refresh() async {
    overlayGranted = await _check(NativeChannel.checkOverlayPermission);
    exactAlarmAllowed = await _check(NativeChannel.canScheduleExactAlarms);
    notificationsGranted = await _check(NativeChannel.checkNotificationPermission);
    notifyListeners();
  }

  Future<void> openOverlaySettings() => _open(NativeChannel.openOverlaySettings);
  Future<void> openExactAlarmSettings() => _open(NativeChannel.openExactAlarmSettings);
  Future<void> requestNotifications() => _open(NativeChannel.requestNotificationPermission);
  Future<void> openBatterySettings() => _open(NativeChannel.openBatterySettings);

  Future<bool> _check(String method) async {
    try {
      return await _bridge.call<bool>(method) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> _open(String method) async {
    try {
      await _bridge.call<void>(method);
    } on PlatformException {
      // Settings screen unavailable on this device; status simply stays unchanged.
    } on MissingPluginException {
      // Not running on Android.
    }
  }
}
