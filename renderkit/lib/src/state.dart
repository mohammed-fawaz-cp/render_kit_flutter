import 'package:flutter/widgets.dart';

class RenderBind<T> {
  final String key;
  const RenderBind(this.key);

  T resolve(BuildContext context) {
    final state = RenderPreviewState.of(context);
    final val = state[key];
    if (val == null) {
      throw Exception("State key '$key' not found in RenderPreviewState.");
    }
    return val as T;
  }
}

class RenderPreviewState extends InheritedWidget {
  final Map<String, dynamic> state;

  const RenderPreviewState({
    super.key,
    required this.state,
    required super.child,
  });

  static Map<String, dynamic> of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RenderPreviewState>();
    return provider?.state ?? const {};
  }

  @override
  bool updateShouldNotify(RenderPreviewState oldWidget) => oldWidget.state != state;
}

T resolveValue<T>(BuildContext context, dynamic value) {
  if (value is RenderBind) {
    return value.resolve(context) as T;
  }
  return value as T;
}
