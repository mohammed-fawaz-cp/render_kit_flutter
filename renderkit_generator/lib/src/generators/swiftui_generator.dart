import '../ir.dart';

class SwiftUIGenerator {
  String generate(String className, IRWidget rootWidget) {
    final buffer = StringBuffer();
    buffer.writeln('import SwiftUI');
    buffer.writeln();
    buffer.writeln(generateScreen(className, rootWidget));
    return buffer.toString();
  }

  String generateScreen(String className, IRWidget rootWidget) {
    final buffer = StringBuffer();
    buffer.writeln('struct $className: View {');
    buffer.writeln('    let state: [String: Any]');
    buffer.writeln('    let onEvent: (String, [String: Any]) -> Void');
    buffer.writeln();
    buffer.writeln('    var body: some View {');
    buffer.write(_generateWidget(rootWidget, '        ', 'onEvent'));
    buffer.writeln('    }');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateWidget(IRWidget widget, String indent, String eventCallback) {
    final buffer = StringBuffer();
    switch (widget.type) {
      case 'RenderColumn':
        buffer.writeln('${indent}VStack {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderRow':
        buffer.writeln('${indent}HStack {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderStack':
        buffer.writeln('${indent}ZStack {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderSpacer':
        buffer.writeln('${indent}Spacer()');
        break;

      case 'RenderExpanded':
        // In SwiftUI, child within Stack expand naturally, or we wrap in frame/Spacer.
        final child = widget.children.first;
        buffer.writeln('${indent}Group {');
        buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        buffer.writeln('${indent}}');
        break;

      case 'RenderCenter':
        final child = widget.children.first;
        buffer.writeln('${indent}VStack {');
        buffer.writeln('${indent}    Spacer()');
        buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        buffer.writeln('${indent}    Spacer()');
        buffer.writeln('${indent}}');
        break;

      case 'RenderAlign':
        final child = widget.children.first;
        final alignVal = widget.properties['alignment'] ?? 'center';
        buffer.writeln('${indent}VStack {');
        buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        buffer.writeln('${indent}}.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .${_mapAlignment(alignVal)})');
        break;

      case 'RenderPositioned':
        final child = widget.children.first;
        final left = widget.properties['left'] ?? 0.0;
        final top = widget.properties['top'] ?? 0.0;
        final right = widget.properties['right'];
        final bottom = widget.properties['bottom'];

        var align = '.topLeading';
        var offsetX = '$left';
        var offsetY = '$top';

        if (right != null && bottom != null) {
          align = '.bottomTrailing';
          offsetX = '-$right';
          offsetY = '-$bottom';
        } else if (right != null) {
          align = '.topTrailing';
          offsetX = '-$right';
        } else if (bottom != null) {
          align = '.bottomLeading';
          offsetY = '-$bottom';
        }

        buffer.write(_generateWidget(child, indent, eventCallback));
        buffer.writeln('${indent}    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: $align)');
        buffer.writeln('${indent}    .offset(x: $offsetX, y: $offsetY)');
        break;

      case 'RenderPadding':
        final child = widget.children.first;
        final paddingProp = widget.properties['padding'];
        final paddingStr = _parsePadding(paddingProp);
        buffer.write(_generateWidget(child, indent, eventCallback));
        buffer.writeln('${indent}    .padding($paddingStr)');
        break;

      case 'RenderContainer':
        final decorationProp = widget.properties['decoration'];
        buffer.write(_generateWidget(widget.children.isNotEmpty ? widget.children.first : IRWidget(type: 'RenderSpacer', properties: {}, children: []), indent, eventCallback));
        final frameStr = _parseContainerFrame(widget.properties);
        if (frameStr.isNotEmpty) {
          buffer.writeln('${indent}    .frame($frameStr)');
        }
        final bgStr = _parseContainerBackground(decorationProp);
        if (bgStr.isNotEmpty) {
          buffer.writeln('${indent}    .background($bgStr)');
        }
        break;

      case 'RenderText':
        final textVal = widget.properties['value'];
        final textExpr = _resolveExpression(textVal, 'String');
        buffer.writeln('${indent}Text($textExpr)');
        break;

      case 'RenderImage':
        final srcVal = widget.properties['value'];
        final srcExpr = _resolveExpression(srcVal, 'String');
        buffer.writeln('${indent}AsyncImage(url: URL(string: $srcExpr)) { image in');
        buffer.writeln('${indent}    image.resizable().aspectRatio(contentMode: .fit)');
        buffer.writeln('${indent}} placeholder: {');
        buffer.writeln('${indent}    ProgressView()');
        buffer.writeln('${indent}}');
        break;

      case 'RenderIcon':
        final iconName = widget.properties['value'] ?? 'help';
        buffer.writeln('${indent}Image(systemName: "${_mapIconName(iconName)}")');
        break;

      case 'RenderDivider':
        buffer.writeln('${indent}Divider()');
        break;

      case 'RenderButton':
        final textVal = widget.properties['text'];
        final actionVal = widget.properties['action'] as IRAction?;
        final actionName = actionVal?.name ?? 'UnknownAction';
        buffer.writeln('${indent}Button(action: { $eventCallback("$actionName", [:]) }) {');
        if (widget.children.isNotEmpty) {
          buffer.write(_generateWidget(widget.children.first, '$indent    ', eventCallback));
        } else if (textVal != null) {
          final textExpr = _resolveExpression(textVal, 'String');
          buffer.writeln('${indent}    Text($textExpr)');
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderIconButton':
        final actionVal = widget.properties['action'] as IRAction?;
        final actionName = actionVal?.name ?? 'UnknownAction';
        buffer.writeln('${indent}Button(action: { $eventCallback("$actionName", [:]) }) {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderCircleAvatar':
        final radius = widget.properties['radius'] ?? 24.0;
        final diameter = radius * 2;
        final bgImg = widget.properties['backgroundImage'];
        final bgCol = widget.properties['backgroundColor'];

        var avatarBg = 'Color.gray';
        if (bgCol is IRProperty) {
          final colorVal = bgCol.properties['value'];
          if (colorVal is int) {
            final r = ((colorVal >> 16) & 0xFF) / 255.0;
            final g = ((colorVal >> 8) & 0xFF) / 255.0;
            final b = (colorVal & 0xFF) / 255.0;
            final a = ((colorVal >> 24) & 0xFF) / 255.0;
            avatarBg = 'Color(red: $r, green: $g, blue: $b, opacity: $a)';
          }
        }

        if (bgImg != null) {
          final bgExpr = _resolveExpression(bgImg, 'String');
          buffer.writeln('${indent}AsyncImage(url: URL(string: $bgExpr)) { image in');
          buffer.writeln('${indent}    image.resizable().aspectRatio(contentMode: .fill)');
          buffer.writeln('${indent}} placeholder: {');
          buffer.writeln('${indent}    $avatarBg');
          buffer.writeln('${indent}}');
          buffer.writeln('${indent}.frame(width: $diameter, height: $diameter)');
          buffer.writeln('${indent}.clipShape(Circle())');
        } else {
          buffer.writeln('${indent}Circle()');
          buffer.writeln('${indent}    .fill($avatarBg)');
          buffer.writeln('${indent}    .frame(width: $diameter, height: $diameter)');
        }
        break;

      case 'RenderCard':
        final decorationProp = widget.properties['decoration'];
        final bgStr = decorationProp != null ? _parseContainerBackground(decorationProp) : '';
        buffer.writeln('${indent}VStack {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        if (bgStr.isNotEmpty) {
          buffer.writeln('${indent}.background($bgStr)');
        } else {
          buffer.writeln('${indent}.background(Color.white)');
        }
        buffer.writeln('${indent}.cornerRadius(8)');
        buffer.writeln('${indent}.shadow(radius: 4)');
        break;

      case 'RenderVisibility':
        final visibleVal = widget.properties['visible'];
        final visibleExpr = _resolveExpression(visibleVal, 'Boolean');
        buffer.writeln('${indent}if $visibleExpr {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderIf':
        final condVal = widget.properties['condition'];
        final condExpr = _resolveExpression(condVal, 'Boolean');
        final trueChild = widget.properties['trueChild'] as IRWidget?;
        final falseChild = widget.properties['falseChild'] as IRWidget?;
        buffer.writeln('${indent}if $condExpr {');
        if (trueChild != null) {
          buffer.write(_generateWidget(trueChild, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}} else {');
        if (falseChild != null) {
          buffer.write(_generateWidget(falseChild, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderSwitch':
        final switchVal = widget.properties['value'];
        final switchExpr = _resolveExpression(switchVal, 'String');
        final casesMap = widget.properties['cases'];
        final defaultChild = widget.properties['defaultChild'] as IRWidget?;
        buffer.writeln('${indent}switch $switchExpr {');
        if (casesMap is Map<String, dynamic>) {
          casesMap.forEach((key, val) {
            if (val is IRWidget) {
              buffer.writeln('${indent}case "$key":');
              buffer.write(_generateWidget(val, '$indent    ', eventCallback));
            }
          });
        }
        buffer.writeln('${indent}default:');
        if (defaultChild != null) {
          buffer.write(_generateWidget(defaultChild, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderResponsive':
        final mobile = widget.properties['mobile'] as IRWidget?;
        final tablet = widget.properties['tablet'] as IRWidget?;
        final desktop = widget.properties['desktop'] as IRWidget?;
        buffer.writeln('${indent}GeometryReader { geometry in');
        buffer.writeln('${indent}    if geometry.size.width < 600 {');
        if (mobile != null) {
          buffer.write(_generateWidget(mobile, '$indent        ', eventCallback));
        }
        buffer.writeln('${indent}    } else if geometry.size.width < 960 {');
        if (tablet != null) {
          buffer.write(_generateWidget(tablet, '$indent        ', eventCallback));
        } else if (mobile != null) {
          buffer.write(_generateWidget(mobile, '$indent        ', eventCallback));
        }
        buffer.writeln('${indent}    } else {');
        if (desktop != null) {
          buffer.write(_generateWidget(desktop, '$indent        ', eventCallback));
        } else if (tablet != null) {
          buffer.write(_generateWidget(tablet, '$indent        ', eventCallback));
        } else if (mobile != null) {
          buffer.write(_generateWidget(mobile, '$indent        ', eventCallback));
        }
        buffer.writeln('${indent}    }');
        buffer.writeln('${indent}}');
        break;

      default:
        buffer.writeln('${indent}// Unknown widget: ${widget.type}');
    }
    return buffer.toString();
  }

  String _resolveExpression(dynamic val, String expectedType) {
    if (val is IRBinding) {
      if (expectedType == 'Boolean') {
        return '(state["${val.key}"] as? Bool) ?? false';
      } else if (expectedType == 'Number') {
        return '(state["${val.key}"] as? Double) ?? 0.0';
      }
      return 'String(describing: state["${val.key}"] ?? "")';
    }
    if (val is String) {
      return '"$val"';
    }
    return val.toString();
  }

  String _mapAlignment(String align) {
    switch (align) {
      case 'topLeft': return 'topLeading';
      case 'topCenter': return 'top';
      case 'topRight': return 'topTrailing';
      case 'centerLeft': return 'leading';
      case 'center': return 'center';
      case 'centerRight': return 'trailing';
      case 'bottomLeft': return 'bottomLeading';
      case 'bottomCenter': return 'bottom';
      case 'bottomRight': return 'bottomTrailing';
      default: return 'center';
    }
  }

  String _mapIconName(String icon) {
    switch (icon) {
      case 'phone': return 'phone.fill';
      case 'close': return 'xmark';
      case 'call_end': return 'phone.down.fill';
      case 'check': return 'checkmark';
      default: return 'questionmark';
    }
  }

  String _parsePadding(dynamic paddingProp) {
    if (paddingProp is IRProperty) {
      final type = paddingProp.type;
      final props = paddingProp.properties;
      if (type == 'RenderInsets.all') {
        return '.all, ${props['left']}';
      } else if (type == 'RenderInsets.symmetric') {
        // Simple return leading/trailing and top/bottom padding
        return 'EdgeInsets(top: ${props['top'] ?? 0.0}, leading: ${props['left'] ?? 0.0}, bottom: ${props['top'] ?? 0.0}, trailing: ${props['left'] ?? 0.0})';
      } else if (type == 'RenderInsets.only') {
        return 'EdgeInsets(top: ${props['top'] ?? 0.0}, leading: ${props['left'] ?? 0.0}, bottom: ${props['bottom'] ?? 0.0}, trailing: ${props['right'] ?? 0.0})';
      }
    }
    return '';
  }

  String _parseContainerFrame(Map<String, dynamic> props) {
    final width = props['width'];
    final height = props['height'];
    final list = <String>[];
    if (width != null) list.add('width: $width');
    if (height != null) list.add('height: $height');
    return list.join(', ');
  }

  String _parseContainerBackground(dynamic deco) {
    if (deco is IRProperty) {
      final bgImg = deco.properties['backgroundImage'];
      if (bgImg != null) {
        final bgExpr = _resolveExpression(bgImg, 'String');
        return 'AnyView(AsyncImage(url: URL(string: $bgExpr)) { image in image.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.clear })';
      }
      final color = deco.properties['color'];
      if (color is IRProperty) {
        final colorVal = color.properties['value'];
        if (colorVal is int) {
          final r = ((colorVal >> 16) & 0xFF) / 255.0;
          final g = ((colorVal >> 8) & 0xFF) / 255.0;
          final b = (colorVal & 0xFF) / 255.0;
          final a = ((colorVal >> 24) & 0xFF) / 255.0;
          return 'Color(red: $r, green: $g, blue: $b, opacity: $a)';
        }
      }
    }
    return '';
  }
}
