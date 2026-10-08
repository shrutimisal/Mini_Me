import 'package:flutter/services.dart';

import '../constants/native_channel.dart';

/// The only place that touches the MethodChannel.
class NativeBridge {
  const NativeBridge();

  static const _channel = MethodChannel(NativeChannel.name);

  Future<T?> call<T>(String method, [Object? arguments]) =>
      _channel.invokeMethod<T>(method, arguments);
}
