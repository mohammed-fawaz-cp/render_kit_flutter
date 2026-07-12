import 'package:renderkit/renderkit.dart' as rk;
import 'render_kit_platform_interface.dart';

export 'package:renderkit/renderkit.dart' hide RenderKit;

class RenderKit {
  static Stream<rk.RenderEvent> get events => rk.RenderKit.events;
  static void emit(rk.RenderEvent event) => rk.RenderKit.emit(event);

  Future<String?> getPlatformVersion() {
    return RenderKitPlatform.instance.getPlatformVersion();
  }
}
