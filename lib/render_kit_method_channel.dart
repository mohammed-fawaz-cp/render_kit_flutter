import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'render_kit_platform_interface.dart';

/// An implementation of [RenderKitPlatform] that uses method channels.
class MethodChannelRenderKit extends RenderKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('render_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
