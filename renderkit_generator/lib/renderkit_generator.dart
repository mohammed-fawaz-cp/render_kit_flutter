import 'dart:async';
import 'package:build/build.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'src/parser.dart';
import 'src/generators/compose_generator.dart';
import 'src/generators/swiftui_generator.dart';

class RenderKitBuilder implements Builder {
  @override
  final Map<String, List<String>> buildExtensions = const {
    '.dart': ['.compose.kt', '.swift']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    
    final library = await resolver.libraryFor(buildStep.inputId);

    final composeScreens = <String>[];
    final swiftScreens = <String>[];

    final composeGen = ComposeGenerator();
    final swiftGen = SwiftUIGenerator();

    for (final unit in library.units) {
      for (final classElement in unit.classes) {
        bool hasRenderEntry = false;
        for (final metadata in classElement.metadata) {
          final annotName = metadata.element?.displayName ?? metadata.toSource();
          if (annotName.contains('RenderEntry')) {
            hasRenderEntry = true;
            break;
          }
        }
        if (!hasRenderEntry) continue;

        final astUnit = await resolver.compilationUnitFor(buildStep.inputId);
        final className = classElement.name;

        ClassDeclaration? classNode;
        for (final decl in astUnit.declarations) {
          if (decl is ClassDeclaration && decl.name.lexeme == className) {
            classNode = decl;
            break;
          }
        }
        if (classNode == null) continue;

        MethodDeclaration? buildMethodNode;
        for (final member in classNode.members) {
          if (member is MethodDeclaration && member.name.lexeme == 'build') {
            buildMethodNode = member;
            break;
          }
        }
        if (buildMethodNode == null) continue;

        final parser = RenderKitParser();
        final irWidget = parser.parseBuildMethod(buildMethodNode);

        if (parser.diagnostics.isNotEmpty) {
          for (final diag in parser.diagnostics) {
            log.warning('[RenderKit Compiler Diagnostic] $diag');
          }
        }

        if (irWidget == null) continue;

        // Generate individual Compose screen code
        final composeScreen = composeGen.generateScreen(className, irWidget);
        composeScreens.add(composeScreen);

        // Generate individual SwiftUI screen code
        final swiftScreen = swiftGen.generateScreen(className, irWidget);
        swiftScreens.add(swiftScreen);
      }
    }

    if (composeScreens.isEmpty && swiftScreens.isEmpty) return;

    // Write Compose once with package/imports
    final composeBuffer = StringBuffer();
    composeBuffer.writeln('package com.renderkit.generated');
    composeBuffer.writeln();
    composeBuffer.writeln('import androidx.compose.runtime.*');
    composeBuffer.writeln('import androidx.compose.ui.*');
    composeBuffer.writeln('import androidx.compose.foundation.layout.*');
    composeBuffer.writeln('import androidx.compose.material3.*');
    composeBuffer.writeln('import androidx.compose.ui.unit.dp');
    composeBuffer.writeln('import androidx.compose.ui.unit.sp');
    composeBuffer.writeln('import androidx.compose.ui.graphics.Color');
    composeBuffer.writeln('import androidx.compose.foundation.shape.CircleShape');
    composeBuffer.writeln('import androidx.compose.ui.draw.clip');
    composeBuffer.writeln();
    for (final screen in composeScreens) {
      composeBuffer.writeln(screen);
      composeBuffer.writeln();
    }
    final composeAsset = buildStep.inputId.changeExtension('.compose.kt');
    await buildStep.writeAsString(composeAsset, composeBuffer.toString());

    // Write SwiftUI once with imports
    final swiftBuffer = StringBuffer();
    swiftBuffer.writeln('import SwiftUI');
    swiftBuffer.writeln();
    for (final screen in swiftScreens) {
      swiftBuffer.writeln(screen);
      swiftBuffer.writeln();
    }
    final swiftAsset = buildStep.inputId.changeExtension('.swift');
    await buildStep.writeAsString(swiftAsset, swiftBuffer.toString());
  }
}

Builder renderKitBuilder(BuilderOptions options) => RenderKitBuilder();
