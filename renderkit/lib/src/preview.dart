import 'package:flutter/widgets.dart';
import 'widgets.dart';
import 'state.dart';

class RenderPreview extends StatelessWidget {
  final RenderWidget child;
  final Map<String, dynamic> state;

  const RenderPreview({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return RenderPreviewState(
      state: state,
      child: Builder(
        builder: (innerContext) {
          return child.toFlutter(innerContext);
        },
      ),
    );
  }
}
