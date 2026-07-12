import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart' as flutter;
import 'properties.dart';
import 'state.dart';
import 'actions.dart';

abstract class RenderWidget {
  const RenderWidget();

  RenderWidget build(flutter.BuildContext context) {
    throw UnimplementedError("build() is not implemented on ${runtimeType}.");
  }

  flutter.Widget toFlutter(flutter.BuildContext context) {
    return build(context).toFlutter(context);
  }
}

// Layout Widgets
class RenderColumn extends RenderWidget {
  final List<RenderWidget> children;
  final RenderAlignment alignment;

  const RenderColumn({
    required this.children,
    this.alignment = RenderAlignment.topCenter,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Column(
      mainAxisAlignment: flutter.MainAxisAlignment.start,
      crossAxisAlignment: flutter.CrossAxisAlignment.center,
      children: children.map((c) => c.toFlutter(context)).toList(),
    );
  }
}

class RenderRow extends RenderWidget {
  final List<RenderWidget> children;
  final RenderAlignment alignment;

  const RenderRow({
    required this.children,
    this.alignment = RenderAlignment.centerLeft,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Row(
      mainAxisAlignment: flutter.MainAxisAlignment.start,
      crossAxisAlignment: flutter.CrossAxisAlignment.center,
      children: children.map((c) => c.toFlutter(context)).toList(),
    );
  }
}

class RenderStack extends RenderWidget {
  final List<RenderWidget> children;

  const RenderStack({
    required this.children,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Stack(
      children: children.map((c) => c.toFlutter(context)).toList(),
    );
  }
}

class RenderContainer extends RenderWidget {
  final RenderWidget? child;
  final RenderDecoration? decoration;
  final RenderConstraints? constraints;
  final dynamic width; // double or RenderBind<double>
  final dynamic height; // double or RenderBind<double>

  const RenderContainer({
    this.child,
    this.decoration,
    this.constraints,
    this.width,
    this.height,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    final double? w = width != null ? resolveValue<double>(context, width) : null;
    final double? h = height != null ? resolveValue<double>(context, height) : null;
    return flutter.Container(
      width: w,
      height: h,
      decoration: decoration?.toFlutter(),
      constraints: constraints?.toFlutter(),
      child: child?.toFlutter(context),
    );
  }
}

class RenderPadding extends RenderWidget {
  final RenderInsets padding;
  final RenderWidget child;

  const RenderPadding({
    required this.padding,
    required this.child,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Padding(
      padding: padding.toFlutter(),
      child: child.toFlutter(context),
    );
  }
}

class RenderSpacer extends RenderWidget {
  const RenderSpacer();

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return const flutter.Spacer();
  }
}

class RenderExpanded extends RenderWidget {
  final RenderWidget child;
  final int flex;

  const RenderExpanded({
    required this.child,
    this.flex = 1,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Expanded(
      flex: flex,
      child: child.toFlutter(context),
    );
  }
}

class RenderAlign extends RenderWidget {
  final RenderAlignment alignment;
  final RenderWidget child;

  const RenderAlign({
    required this.alignment,
    required this.child,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Align(
      alignment: alignment.toFlutter(),
      child: child.toFlutter(context),
    );
  }
}

class RenderCenter extends RenderWidget {
  final RenderWidget child;

  const RenderCenter({
    required this.child,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Center(
      child: child.toFlutter(context),
    );
  }
}

class RenderPositioned extends RenderWidget {
  final RenderWidget child;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  const RenderPositioned({
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: child.toFlutter(context),
    );
  }
}

// Display Widgets
class RenderText extends RenderWidget {
  final dynamic text; // String or RenderBind<String>
  final RenderTextStyle? style;

  const RenderText(
    this.text, {
    this.style,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    final String resolvedText = resolveValue<String>(context, text);
    return flutter.Text(
      resolvedText,
      style: style?.toFlutter(),
    );
  }
}

class RenderImage extends RenderWidget {
  final dynamic source; // String (URL/Asset) or RenderBind<String>

  const RenderImage(
    this.source,
  );

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    final String resolvedSource = resolveValue<String>(context, source);
    if (resolvedSource.startsWith('http')) {
      return flutter.Image.network(resolvedSource);
    }
    return flutter.Image.asset(resolvedSource);
  }
}

class RenderIcon extends RenderWidget {
  final String name; // e.g. "phone", "close"
  final RenderColor? color;
  final double? size;

  const RenderIcon(
    this.name, {
    this.color,
    this.size,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    // Map simple icon names to Material icons
    flutter.IconData iconData = material.Icons.help;
    switch (name) {
      case 'phone':
        iconData = material.Icons.phone;
        break;
      case 'close':
        iconData = material.Icons.close;
        break;
      case 'call_end':
        iconData = material.Icons.call_end;
        break;
      case 'check':
        iconData = material.Icons.check;
        break;
    }
    return flutter.Icon(
      iconData,
      color: color?.toFlutter(),
      size: size,
    );
  }
}

class RenderDivider extends RenderWidget {
  final RenderColor? color;
  final double thickness;

  const RenderDivider({
    this.color,
    this.thickness = 1.0,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return material.Divider(
      color: color?.toFlutter(),
      thickness: thickness,
    );
  }
}

// Controls
class RenderButton extends RenderWidget {
  final RenderAction action;
  final RenderWidget? child;
  final dynamic text; // String or RenderBind<String>

  const RenderButton({
    required this.action,
    this.child,
    this.text,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return material.ElevatedButton(
      onPressed: () {
        RenderKit.emit(RenderEvent(action));
      },
      child: child != null
          ? child!.toFlutter(context)
          : flutter.Text(resolveValue<String>(context, text ?? '')),
    );
  }
}

class RenderIconButton extends RenderWidget {
  final RenderAction action;
  final RenderIcon icon;

  const RenderIconButton({
    required this.action,
    required this.icon,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return material.IconButton(
      icon: icon.toFlutter(context),
      onPressed: () {
        RenderKit.emit(RenderEvent(action));
      },
    );
  }
}

// Decoration
class RenderCard extends RenderWidget {
  final RenderWidget child;
  final RenderDecoration? decoration;

  const RenderCard({
    required this.child,
    this.decoration,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.Container(
      decoration: decoration?.toFlutter() ??
          flutter.BoxDecoration(
            color: material.Colors.white,
            borderRadius: flutter.BorderRadius.circular(8.0),
            boxShadow: const [
              flutter.BoxShadow(
                color: flutter.Color(0x1A000000),
                blurRadius: 4.0,
                offset: flutter.Offset(0.0, 2.0),
              )
            ],
          ),
      child: child.toFlutter(context),
    );
  }
}

class RenderCircleAvatar extends RenderWidget {
  final dynamic backgroundImage; // String or RenderBind<String>
  final double radius;

  const RenderCircleAvatar({
    this.backgroundImage,
    this.radius = 24.0,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    final String? img = backgroundImage != null
        ? resolveValue<String>(context, backgroundImage)
        : null;
    return material.CircleAvatar(
      radius: radius,
      backgroundImage: img != null
          ? (img.startsWith('http')
              ? flutter.NetworkImage(img)
              : flutter.AssetImage(img) as flutter.ImageProvider)
          : null,
    );
  }
}

// Visibility and conditionals
class RenderVisibility extends RenderWidget {
  final dynamic visible; // bool or RenderBind<bool>
  final RenderWidget child;

  const RenderVisibility({
    required this.visible,
    required this.child,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    final bool isVisible = resolveValue<bool>(context, visible);
    return flutter.Visibility(
      visible: isVisible,
      child: child.toFlutter(context),
    );
  }
}

class RenderIf extends RenderWidget {
  final dynamic condition; // bool or RenderBind<bool>
  final RenderWidget trueChild;
  final RenderWidget falseChild;

  const RenderIf({
    required this.condition,
    required this.trueChild,
    required this.falseChild,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    final bool cond = resolveValue<bool>(context, condition);
    return cond ? trueChild.toFlutter(context) : falseChild.toFlutter(context);
  }
}

class RenderSwitch extends RenderWidget {
  final dynamic value; // String or RenderBind<String>
  final Map<String, RenderWidget> cases;
  final RenderWidget defaultChild;

  const RenderSwitch({
    required this.value,
    required this.cases,
    required this.defaultChild,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    final String val = resolveValue<String>(context, value);
    final match = cases[val];
    return match != null ? match.toFlutter(context) : defaultChild.toFlutter(context);
  }
}

class RenderResponsive extends RenderWidget {
  final RenderWidget mobile;
  final RenderWidget? tablet;
  final RenderWidget? desktop;

  const RenderResponsive({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  flutter.Widget toFlutter(flutter.BuildContext context) {
    return flutter.LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900 && desktop != null) {
          return desktop!.toFlutter(context);
        }
        if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!.toFlutter(context);
        }
        return mobile.toFlutter(context);
      },
    );
  }
}
