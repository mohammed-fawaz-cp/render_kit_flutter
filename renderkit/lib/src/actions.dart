import 'dart:async';
import 'package:flutter/widgets.dart';

abstract class RenderAction {
  const RenderAction();
  Map<String, dynamic> toJson();
}

class RenderEvent {
  final RenderAction action;
  final Map<String, dynamic> payload;
  
  const RenderEvent(this.action, [this.payload = const {}]);

  Map<String, dynamic> toJson() => {
    'action': action.toJson(),
    'payload': payload,
  };
}

class RenderKit {
  static final StreamController<RenderEvent> _eventController = StreamController<RenderEvent>.broadcast();
  
  static Stream<RenderEvent> get events => _eventController.stream;

  static void emit(RenderEvent event) {
    _eventController.add(event);
  }
}

class RenderEventListener extends StatefulWidget {
  final Widget Function(BuildContext context, RenderEvent? lastEvent) builder;
  
  const RenderEventListener({
    super.key,
    required this.builder,
  });

  @override
  State<RenderEventListener> createState() => _RenderEventListenerState();
}

class _RenderEventListenerState extends State<RenderEventListener> {
  StreamSubscription<RenderEvent>? _subscription;
  RenderEvent? _lastEvent;

  @override
  void initState() {
    super.initState();
    _subscription = RenderKit.events.listen((event) {
      setState(() {
        _lastEvent = event;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _lastEvent);
  }
}
