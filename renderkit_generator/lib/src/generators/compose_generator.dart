import '../ir.dart';

class ComposeGenerator {
  String generate(String className, IRWidget rootWidget) {
    final buffer = StringBuffer();
    buffer.writeln('package com.renderkit.generated');
    buffer.writeln();
    buffer.writeln('import androidx.compose.runtime.*');

    buffer.writeln('import androidx.compose.ui.*');
    buffer.writeln('import androidx.compose.foundation.layout.*');
    buffer.writeln('import androidx.compose.material3.*');
    buffer.writeln('import androidx.compose.ui.unit.dp');
    buffer.writeln('import androidx.compose.ui.unit.sp');
    buffer.writeln('import androidx.compose.ui.graphics.Color');
    buffer.writeln('import androidx.compose.foundation.shape.CircleShape');
    buffer.writeln('import androidx.compose.ui.draw.clip');
    buffer.writeln('import androidx.compose.foundation.background');
    buffer.writeln('import androidx.compose.ui.layout.ContentScale');
    buffer.writeln('import coil.compose.AsyncImage');
    buffer.writeln('import androidx.compose.material.icons.Icons');
    buffer.writeln('import androidx.compose.material.icons.filled.*');
    buffer.writeln();
    buffer.writeln(generateScreen(className, rootWidget));
    return buffer.toString();
  }

  String generateScreen(String className, IRWidget rootWidget) {
    final buffer = StringBuffer();
    buffer.writeln('@Composable');
    buffer.writeln('fun $className(');
    buffer.writeln('    state: Map<String, Any>,');
    buffer.writeln('    onEvent: (actionName: String, args: Map<String, Any>) -> Unit');
    buffer.writeln(') {');
    
    buffer.writeln(_generateWidget(rootWidget, '    ', 'onEvent'));

    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateWidget(IRWidget widget, String indent, String eventCallback) {
    final buffer = StringBuffer();
    switch (widget.type) {
      case 'RenderColumn':
        buffer.writeln('${indent}Column(');
        buffer.writeln('${indent}    modifier = Modifier.fillMaxWidth()');
        buffer.writeln('${indent}) {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderRow':
        buffer.writeln('${indent}Row(');
        buffer.writeln('${indent}    modifier = Modifier.fillMaxWidth()');
        buffer.writeln('${indent}) {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderStack':
        buffer.writeln('${indent}Box {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderSpacer':
        buffer.writeln('${indent}Spacer(modifier = Modifier.weight(1f))');
        break;

      case 'RenderExpanded':
        final child = widget.children.first;
        buffer.writeln('${indent}Box(modifier = Modifier.weight(1f)) {');
        buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        buffer.writeln('${indent}}');
        break;

      case 'RenderCenter':
        final child = widget.children.first;
        buffer.writeln('${indent}Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {');
        buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        buffer.writeln('${indent}}');
        break;

      case 'RenderAlign':
        final child = widget.children.first;
        final alignVal = widget.properties['alignment'] ?? 'center';
        buffer.writeln('${indent}Box(contentAlignment = Alignment.${_mapAlignment(alignVal)}, modifier = Modifier.fillMaxSize()) {');
        buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        buffer.writeln('${indent}}');
        break;

      case 'RenderPadding':
        final child = widget.children.first;
        final paddingProp = widget.properties['padding'];
        final paddingStr = _parsePadding(paddingProp);
        buffer.writeln('${indent}Box(modifier = Modifier.padding($paddingStr)) {');
        buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        buffer.writeln('${indent}}');
        break;

      case 'RenderContainer':
        final decorationProp = widget.properties['decoration'];
        final modifierStr = _parseContainerModifier(widget.properties, decorationProp);
        buffer.writeln('${indent}Box(modifier = $modifierStr) {');
        if (decorationProp is IRProperty) {
          final bgImg = decorationProp.properties['backgroundImage'];
          if (bgImg != null) {
            final bgExpr = _resolveExpression(bgImg, 'String');
            buffer.writeln('${indent}    AsyncImage(');
            buffer.writeln('${indent}        model = $bgExpr,');
            buffer.writeln('${indent}        contentDescription = null,');
            buffer.writeln('${indent}        contentScale = ContentScale.Crop,');
            buffer.writeln('${indent}        modifier = Modifier.matchParentSize()');
            buffer.writeln('${indent}    )');
          }
        }
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderText':
        final textVal = widget.properties['value'];
        final textExpr = _resolveExpression(textVal, 'String');
        buffer.writeln('${indent}Text(text = $textExpr)');
        break;

      case 'RenderImage':
        final srcVal = widget.properties['value'];
        final srcExpr = _resolveExpression(srcVal, 'String');
        buffer.writeln('${indent}AsyncImage(');
        buffer.writeln('${indent}    model = $srcExpr,');
        buffer.writeln('${indent}    contentDescription = null,');
        buffer.writeln('${indent}    modifier = Modifier.fillMaxWidth()');
        buffer.writeln('${indent})');
        break;

      case 'RenderIcon':
        final iconName = widget.properties['value'] ?? 'help';
        buffer.writeln('${indent}Icon(imageVector = Icons.Default.${_mapIconName(iconName)}, contentDescription = "$iconName")');
        break;

      case 'RenderDivider':
        buffer.writeln('${indent}Divider()');
        break;

      case 'RenderButton':
        final textVal = widget.properties['text'];
        final actionVal = widget.properties['action'] as IRAction?;
        final actionName = actionVal?.name ?? 'UnknownAction';
        buffer.writeln('${indent}Button(onClick = { $eventCallback("$actionName", mapOf()) }) {');
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
        buffer.writeln('${indent}IconButton(onClick = { $eventCallback("$actionName", mapOf()) }) {');
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent    ', eventCallback));
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderCircleAvatar':
        final radius = widget.properties['radius'] ?? 24.0;
        final size = radius * 2;
        final bgImg = widget.properties['backgroundImage'];
        final bgCol = widget.properties['backgroundColor'];

        var avatarModifier = 'Modifier.size(${size}.dp).clip(CircleShape)';
        if (bgCol is IRProperty) {
          final colorVal = bgCol.properties['value'];
          if (colorVal is int) {
            final hex = colorVal.toRadixString(16).padLeft(8, '0');
            avatarModifier += '.background(Color(0x$hex))';
          }
        } else {
          if (bgImg == null) {
            avatarModifier += '.background(Color.Gray)';
          }
        }

        buffer.writeln('${indent}Box(');
        buffer.writeln('${indent}    modifier = $avatarModifier');
        buffer.writeln('${indent}) {');
        if (bgImg != null) {
          final bgExpr = _resolveExpression(bgImg, 'String');
          buffer.writeln('${indent}    AsyncImage(');
          buffer.writeln('${indent}        model = $bgExpr,');
          buffer.writeln('${indent}        contentDescription = null,');
          buffer.writeln('${indent}        contentScale = ContentScale.Crop,');
          buffer.writeln('${indent}        modifier = Modifier.fillMaxSize()');
          buffer.writeln('${indent}    )');
        } else {
          buffer.writeln('${indent}    Text("[Avatar]", modifier = Modifier.align(Alignment.Center))');
        }
        buffer.writeln('${indent}}');
        break;

      case 'RenderCard':
        final decorationProp = widget.properties['decoration'];
        buffer.writeln('${indent}Card(modifier = Modifier.fillMaxWidth()) {');
        buffer.writeln('${indent}    Box(modifier = Modifier.fillMaxWidth()) {');
        if (decorationProp is IRProperty) {
          final bgImg = decorationProp.properties['backgroundImage'];
          if (bgImg != null) {
            final bgExpr = _resolveExpression(bgImg, 'String');
            buffer.writeln('${indent}        AsyncImage(');
            buffer.writeln('${indent}            model = $bgExpr,');
            buffer.writeln('${indent}            contentDescription = null,');
            buffer.writeln('${indent}            contentScale = ContentScale.Crop,');
            buffer.writeln('${indent}            modifier = Modifier.matchParentSize()');
            buffer.writeln('${indent}        )');
          }
        }
        for (final child in widget.children) {
          buffer.write(_generateWidget(child, '$indent        ', eventCallback));
        }
        buffer.writeln('${indent}    }');
        buffer.writeln('${indent}}');
        break;

      case 'RenderVisibility':
        final visibleVal = widget.properties['visible'];
        final visibleExpr = _resolveExpression(visibleVal, 'Boolean');
        buffer.writeln('${indent}if ($visibleExpr) {');
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
        buffer.writeln('${indent}if ($condExpr) {');
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
        return '(state["${val.key}"] as? Boolean) ?: false';
      } else if (expectedType == 'Number') {
        return '(state["${val.key}"] as? Number)?.toDouble() ?: 0.0';
      }
      return 'state["${val.key}"].toString()';
    }
    if (val is String) {
      return '"$val"';
    }
    return val.toString();
  }

  String _mapAlignment(String align) {
    switch (align) {
      case 'topLeft': return 'TopStart';
      case 'topCenter': return 'TopCenter';
      case 'topRight': return 'TopEnd';
      case 'centerLeft': return 'CenterStart';
      case 'center': return 'Center';
      case 'centerRight': return 'CenterEnd';
      case 'bottomLeft': return 'BottomStart';
      case 'bottomCenter': return 'BottomCenter';
      case 'bottomRight': return 'BottomEnd';
      default: return 'Center';
    }
  }

  String _mapIconName(String icon) {
    switch (icon) {
      case 'phone': return 'Phone';
      case 'close': return 'Close';
      case 'call_end': return 'CallEnd';
      case 'check': return 'Check';
      default: return 'Help';
    }
  }

  String _parsePadding(dynamic paddingProp) {
    if (paddingProp is IRProperty) {
      final type = paddingProp.type;
      final props = paddingProp.properties;
      if (type == 'RenderInsets.all') {
        return '${props['left']}.dp';
      } else if (type == 'RenderInsets.symmetric') {
        return 'horizontal = ${props['left'] ?? 0.0}.dp, vertical = ${props['top'] ?? 0.0}.dp';
      } else if (type == 'RenderInsets.only') {
        return 'start = ${props['left'] ?? 0.0}.dp, top = ${props['top'] ?? 0.0}.dp, end = ${props['right'] ?? 0.0}.dp, bottom = ${props['bottom'] ?? 0.0}.dp';
      }
    }
    return '0.dp';
  }

  String _parseContainerModifier(Map<String, dynamic> props, dynamic deco) {
    var modifier = 'Modifier';
    final width = props['width'];
    final height = props['height'];

    if (width != null) {
      modifier += '.width(${width}.dp)';
    }
    if (height != null) {
      modifier += '.height(${height}.dp)';
    }

    if (deco is IRProperty) {
      final color = deco.properties['color'];
      if (color is IRProperty) {
        final colorVal = color.properties['value'];
        if (colorVal is int) {
          final hex = colorVal.toRadixString(16).padLeft(8, '0');
          modifier += '.background(Color(0x$hex))';
        }
      }
    }
    return modifier;
  }
}
