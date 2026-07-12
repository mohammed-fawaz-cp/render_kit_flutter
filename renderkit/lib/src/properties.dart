import 'package:flutter/widgets.dart' as flutter;

class RenderColor {
  final int value;
  const RenderColor(this.value);

  flutter.Color toFlutter() => flutter.Color(value);
}

class RenderDimension {
  final double value;
  final bool isPercent;
  const RenderDimension(this.value, {this.isPercent = false});

  const RenderDimension.percent(this.value) : isPercent = true;

  double toFlutter(double max) {
    if (isPercent) {
      return max * (value / 100.0);
    }
    return value;
  }
}

class RenderInsets {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const RenderInsets.all(double value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  const RenderInsets.symmetric({double vertical = 0.0, double horizontal = 0.0})
      : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  const RenderInsets.only({this.left = 0.0, this.top = 0.0, this.right = 0.0, this.bottom = 0.0});

  flutter.EdgeInsets toFlutter() => flutter.EdgeInsets.fromLTRB(left, top, right, bottom);
}

class RenderBorderRadius {
  final double value;
  const RenderBorderRadius(this.value);

  flutter.BorderRadius toFlutter() => flutter.BorderRadius.circular(value);
}

class RenderBorder {
  final RenderColor color;
  final double width;
  const RenderBorder({required this.color, this.width = 1.0});

  flutter.Border toFlutter() => flutter.Border.all(color: color.toFlutter(), width: width);
}

enum RenderAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight;

  flutter.Alignment toFlutter() {
    switch (this) {
      case RenderAlignment.topLeft: return flutter.Alignment.topLeft;
      case RenderAlignment.topCenter: return flutter.Alignment.topCenter;
      case RenderAlignment.topRight: return flutter.Alignment.topRight;
      case RenderAlignment.centerLeft: return flutter.Alignment.centerLeft;
      case RenderAlignment.center: return flutter.Alignment.center;
      case RenderAlignment.centerRight: return flutter.Alignment.centerRight;
      case RenderAlignment.bottomLeft: return flutter.Alignment.bottomLeft;
      case RenderAlignment.bottomCenter: return flutter.Alignment.bottomCenter;
      case RenderAlignment.bottomRight: return flutter.Alignment.bottomRight;
    }
  }
}

class RenderTextStyle {
  final RenderColor? color;
  final double? fontSize;
  final bool bold;
  final bool italic;

  const RenderTextStyle({
    this.color,
    this.fontSize,
    this.bold = false,
    this.italic = false,
  });

  flutter.TextStyle toFlutter() => flutter.TextStyle(
    color: color?.toFlutter(),
    fontSize: fontSize,
    fontWeight: bold ? flutter.FontWeight.bold : flutter.FontWeight.normal,
    fontStyle: italic ? flutter.FontStyle.italic : flutter.FontStyle.normal,
  );
}

class RenderDecoration {
  final RenderColor? color;
  final RenderBorder? border;
  final RenderBorderRadius? borderRadius;
  final List<RenderShadow>? shadows;

  const RenderDecoration({
    this.color,
    this.border,
    this.borderRadius,
    this.shadows,
  });

  flutter.BoxDecoration toFlutter() => flutter.BoxDecoration(
    color: color?.toFlutter(),
    border: border?.toFlutter(),
    borderRadius: borderRadius?.toFlutter(),
    boxShadow: shadows?.map((s) => s.toFlutter()).toList(),
  );
}

class RenderShadow {
  final RenderColor color;
  final double blurRadius;
  final double offsetX;
  final double offsetY;

  const RenderShadow({
    required this.color,
    this.blurRadius = 0.0,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
  });

  flutter.BoxShadow toFlutter() => flutter.BoxShadow(
    color: color.toFlutter(),
    blurRadius: blurRadius,
    offset: flutter.Offset(offsetX, offsetY),
  );
}

class RenderConstraints {
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  const RenderConstraints({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  flutter.BoxConstraints toFlutter() => flutter.BoxConstraints(
    minWidth: minWidth ?? 0.0,
    maxWidth: maxWidth ?? double.infinity,
    minHeight: minHeight ?? 0.0,
    maxHeight: maxHeight ?? double.infinity,
  );
}
