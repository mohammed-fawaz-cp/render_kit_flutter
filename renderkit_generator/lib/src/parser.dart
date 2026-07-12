import 'package:analyzer/dart/ast/ast.dart';
import 'ir.dart';

class Diagnostic {
  final String code;
  final String message;
  final int offset;
  final int length;

  Diagnostic({
    required this.code,
    required this.message,
    required this.offset,
    required this.length,
  });

  @override
  String toString() => '[$code] $message (at offset $offset)';
}

class RenderKitParser {
  final List<Diagnostic> diagnostics = [];

  IRWidget? parseBuildMethod(MethodDeclaration node) {
    final body = node.body;
    Expression? rootExpression;

    if (body is ExpressionFunctionBody) {
      rootExpression = body.expression;
    } else if (body is BlockFunctionBody) {
      for (final statement in body.block.statements) {
        if (statement is ReturnStatement) {
          rootExpression = statement.expression;
          break;
        }
      }
    }

    if (rootExpression == null) {
      diagnostics.add(Diagnostic(
        code: 'RK003',
        message: 'Could not find a return statement or expression in the build method.',
        offset: node.offset,
        length: node.length,
      ));
      return null;
    }

    final parsed = _parseExpression(rootExpression);
    if (parsed is IRWidget) {
      return parsed;
    } else {
      diagnostics.add(Diagnostic(
        code: 'RK003',
        message: 'The build method must return a valid RenderWidget.',
        offset: rootExpression.offset,
        length: rootExpression.length,
      ));
      return null;
    }
  }

  dynamic _parseExpression(Expression expr) {
    if (expr is SimpleStringLiteral) {
      return expr.value;
    } else if (expr is IntegerLiteral) {
      return expr.value;
    } else if (expr is DoubleLiteral) {
      return expr.value;
    } else if (expr is BooleanLiteral) {
      return expr.value;
    } else if (expr is NullLiteral) {
      return null;
    } else if (expr is PrefixExpression) {
      final operand = _parseExpression(expr.operand);
      if (expr.operator.lexeme == '-' && operand is num) {
        return -operand;
      }
      diagnostics.add(Diagnostic(
        code: 'RK003',
        message: 'Unsupported prefix operator: ${expr.operator.lexeme}',
        offset: expr.offset,
        length: expr.length,
      ));
      return null;
    } else if (expr is ListLiteral) {
      return expr.elements
          .map((e) => _parseExpression(e as Expression))
          .where((e) => e != null)
          .toList();
    } else if (expr is InstanceCreationExpression) {
      final className = expr.constructorName.type.toSource();
      final constructorName = expr.constructorName.name?.name;
      return _parseConstructorCall(className, constructorName, expr.argumentList, expr.offset, expr.length);
    } else if (expr is MethodInvocation) {
      final target = expr.target;
      final methodName = expr.methodName.name;
      if (target == null) {
        return _parseConstructorCall(methodName, null, expr.argumentList, expr.offset, expr.length);
      } else if (target is Identifier) {
        final targetName = target.name;
        if (targetName == 'RenderDimension' && methodName == 'percent') {
          final arg = expr.argumentList.arguments.first;
          final val = _parseExpression(arg);
          return IRProperty(
            type: 'RenderDimension',
            properties: {'value': val, 'isPercent': true},
          );
        }
        return _parseConstructorCall(targetName, methodName, expr.argumentList, expr.offset, expr.length);
      }
      diagnostics.add(Diagnostic(
        code: 'RK003',
        message: 'Unsupported method invocation: ${expr.toSource()}',
        offset: expr.offset,
        length: expr.length,
      ));
      return null;
    } else if (expr is Identifier) {
      final name = expr.name;
      if (name.startsWith('RenderAlignment.')) {
        return name.split('.').last;
      }
      return name;
    } else if (expr is PropertyAccess) {
      final target = expr.target;
      final property = expr.propertyName.name;
      if (target is Identifier && target.name == 'RenderAlignment') {
        return property;
      }
      return expr.toSource();
    }

    diagnostics.add(Diagnostic(
      code: 'RK003',
      message: 'Unsupported syntax: ${expr.runtimeType} (${expr.toSource()})',
      offset: expr.offset,
      length: expr.length,
    ));
    return null;
  }

  dynamic _parseConstructorCall(
    String className,
    String? constructorName,
    ArgumentList argumentList,
    int offset,
    int length,
  ) {
    if (className.contains('.')) {
      final parts = className.split('.');
      className = parts.first;
      constructorName = parts.last;
    }

    // 1. Check if it's a State Binding
    if (className == 'RenderBind') {
      final arg = argumentList.arguments.first;
      final key = _parseExpression(arg);
      if (key is! String || key.isEmpty) {
        diagnostics.add(Diagnostic(
          code: 'RK005',
          message: 'Invalid binding key: must be a non-empty string literal.',
          offset: offset,
          length: length,
        ));
        return IRBinding('invalid');
      }
      return IRBinding(key);
    }

    // 2. Check if it's an Action
    if (className.endsWith('Action')) {
      final args = <String, dynamic>{};
      for (final arg in argumentList.arguments) {
        if (arg is NamedExpression) {
          args[arg.name.label.name] = _parseExpression(arg.expression);
        } else {
          diagnostics.add(Diagnostic(
            code: 'RK004',
            message: 'Action constructors only support named arguments.',
            offset: arg.offset,
            length: arg.length,
          ));
        }
      }
      return IRAction(className, args);
    }

    // Parse all arguments
    final props = <String, dynamic>{};
    final children = <IRWidget>[];

    for (final arg in argumentList.arguments) {
      if (arg is NamedExpression) {
        final name = arg.name.label.name;
        final value = _parseExpression(arg.expression);
        if (name == 'children' && value is List) {
          for (final item in value) {
            if (item is IRWidget) {
              children.add(item);
            }
          }
        } else if (name == 'child' && value is IRWidget) {
          children.add(value);
        } else {
          props[name] = value;
        }
      } else {
        // Positional argument
        final value = _parseExpression(arg);
        if (className == 'RenderText' || className == 'RenderImage' || className == 'RenderIcon') {
          props['value'] = value;
        } else if (className == 'RenderInsets' && constructorName == 'all') {
          props['left'] = value;
          props['top'] = value;
          props['right'] = value;
          props['bottom'] = value;
        } else if (className == 'RenderColor' || className == 'RenderBorderRadius') {
          props['value'] = value;
        } else {
          diagnostics.add(Diagnostic(
            code: 'RK002',
            message: 'Positional arguments are not supported for class $className.',
            offset: arg.offset,
            length: arg.length,
          ));
        }
      }
    }

    // 3. Check if it's a Property class
    const propertyClasses = {
      'RenderColor',
      'RenderDimension',
      'RenderInsets',
      'RenderBorderRadius',
      'RenderBorder',
      'RenderTextStyle',
      'RenderDecoration',
      'RenderShadow',
      'RenderConstraints',
    };

    if (propertyClasses.contains(className)) {
      var typeName = className;
      if (constructorName != null) {
        typeName = '$className.$constructorName';
      }
      return IRProperty(type: typeName, properties: props);
    }

    // 4. Check if it's a Widget
    const widgetClasses = {
      'RenderColumn',
      'RenderRow',
      'RenderStack',
      'RenderContainer',
      'RenderPadding',
      'RenderSpacer',
      'RenderExpanded',
      'RenderAlign',
      'RenderCenter',
      'RenderPositioned',
      'RenderText',
      'RenderImage',
      'RenderIcon',
      'RenderDivider',
      'RenderButton',
      'RenderIconButton',
      'RenderCard',
      'RenderCircleAvatar',
      'RenderVisibility',
      'RenderIf',
      'RenderSwitch',
      'RenderResponsive',
    };

    if (widgetClasses.contains(className)) {
      return IRWidget(type: className, properties: props, children: children);
    }

    // Record RK001 (Unknown Widget)
    diagnostics.add(Diagnostic(
      code: 'RK001',
      message: 'Unknown or unsupported RenderKit widget/class: $className',
      offset: offset,
      length: length,
    ));

    return null;
  }
}
