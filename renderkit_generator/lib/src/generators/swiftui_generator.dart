import '../ir.dart';

class SwiftUIGenerator {
  String generate(String className, IRWidget rootWidget) {
    final buffer = StringBuffer();
    buffer.writeln('import SwiftUI');
    buffer.writeln();
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
        buffer.writeln('${indent}// AsyncImage placeholder for: \\($srcExpr)');
        buffer.writeln('${indent}Text("[Image: " + $srcExpr + "]")');
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
        buffer.writeln('${indent}Text("[Avatar]")');
        buffer.writeln('${indent}    .frame(width: $diameter, height: $diameter)');
        buffer.writeln('${indent}    .clipShape(Circle())');
        break;

      case 'RenderCard':
        buffer.writeln('${indent}VStack {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        buffer.writeln('${indent}.background(Color.white)');
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
        final trueChild = widget.children[0];
        final falseChild = widget.children[1];
        buffer.writeln('${indent}if $condExpr {');
        buffer.write(_generateWidget(trueChild, '$indent    ', eventCallback));
        buffer.writeln('${indent}} else {');
        buffer.write(_generateWidget(falseChild, '$indent    ', eventCallback));
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
