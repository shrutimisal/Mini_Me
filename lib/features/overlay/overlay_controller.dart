import 'package:flutter/services.dart';

import '../../core/constants/native_channel.dart';
import '../../core/platform/native_bridge.dart';

enum OverlayResult { ok, permissionMissing, failed }

/// Flutter-facing API for the native overlay. No Android details leak past here.
class OverlayController {
  OverlayController(this._bridge);

  final NativeBridge _bridge;

  static const defaultMessage = "Hi! I'm MiniMe 👋";

  /// [duration]: null = use the saved setting, Duration.zero = stay until hidden.
  Future<OverlayResult> show({String message = defaultMessage, Duration? duration}) async {
    try {
      await _bridge.call<bool>(NativeChannel.showOverlay, {
        'message': message,
        'durationMs': duration?.inMilliseconds ?? -1,
      });
      return OverlayResult.ok;
    } on PlatformException catch (e) {
      return e.code == 'NO_PERMISSION' ? OverlayResult.permissionMissing : OverlayResult.failed;
    } on MissingPluginException {
      return OverlayResult.failed;
    }
  }

  Future<void> hide() async {
    try {
      await _bridge.call<bool>(NativeChannel.hideOverlay);
    } on PlatformException {
      // Nothing to hide.
    } on MissingPluginException {
      // Not running on Android.
    }
  }

  Future<bool> isShowing() async {
    try {
      return await _bridge.call<bool>(NativeChannel.isOverlayShowing) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
