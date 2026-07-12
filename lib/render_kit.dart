import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:renderkit/renderkit.dart' as rk;
import 'render_kit_platform_interface.dart';

export 'package:renderkit/renderkit.dart' hide RenderKit;

class RenderKit {
  static const MethodChannel _channel = MethodChannel('render_kit_flutter');
  static final Map<String, rk.RenderAction> _actionRegistry = {};

  static Stream<rk.RenderEvent> get events => rk.RenderKit.events;
  static void emit(rk.RenderEvent event) => rk.RenderKit.emit(event);

  /// Registers custom action classes so they can be matched via `is` type checks.
  static void registerActions(List<rk.RenderAction> actions) {
    for (final action in actions) {
      final name = action.toJson()['name'];
      if (name is String) {
        _actionRegistry[name] = action;
      }
    }
  }

  /// Initializes the RenderKit event listener to bridge native clicks back to Dart automatically.
  static void initialize() {
    WidgetsFlutterBinding.ensureInitialized();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'emitEvent') {
        final name = call.arguments['name'] as String;
        final args = Map<String, dynamic>.from(call.arguments['args'] as Map? ?? {});
        
        final action = _actionRegistry[name] ?? GenericRenderAction(name);
        final event = rk.RenderEvent(action, args);
        rk.RenderKit.emit(event);
      }
    });
  }

  /// Navigates to a compiled native screen with a specified state map in a single line.
  static Future<void> navigateTo(String screenName, Map<String, dynamic> state) async {
    await _channel.invokeMethod('navigateTo', {
      'screen': screenName,
      'state': state,
    });
  }

  Future<String?> getPlatformVersion() {
    return RenderKitPlatform.instance.getPlatformVersion();
  }
}

class GenericRenderAction extends rk.RenderAction {
  final String actionName;
  const GenericRenderAction(this.actionName);

  @override
  Map<String, dynamic> toJson() => {'name': actionName};
}

