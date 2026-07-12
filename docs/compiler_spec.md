# RenderKit Compiler & Code Generation Specification

This document details the compilation pipeline, compiler diagnostics, validation checks, and target code generation parameters for RenderKit.

## 1. Compiler Toolchain & IR

The `renderkit_generator` parses the builder target using the Dart `analyzer` library. The build phase performs the following compiler stages:

1. **AST Extraction**: Evaluates the annotated `@RenderEntry` class, locates its `build` method, and extracts the returning expression AST.
2. **Diagnostic Checking**: Inspects nodes recursively, reporting code analysis warnings.
3. **IR Construction**: Emits an `IRWidget` graph. A unified JSON representation of the IR allows debug inspections.

### Unified IR Schema
```json
{
  "type": "RenderColumn",
  "properties": {
    "alignment": "topCenter"
  },
  "children": [
    {
      "type": "RenderText",
      "properties": {
        "value": {
          "__type": "IRBinding",
          "key": "callerName"
        }
      },
      "children": []
    }
  ]
}
```

---

## 2. Compiler Diagnostics & Codes

RenderKit generates static diagnostics during AST parsing:

| Code | Name | Description | Severity |
|---|---|---|---|
| **RK001** | Unknown Widget | Class name does not map to a supported RenderKit layout or control. | Error |
| **RK002** | Unknown Property | Constructor property is not registered or supported by the target widget. | Error |
| **RK003** | Unsupported Expression | Dart code logic (e.g. conditional if/else, loops) found in `build` instead of declarative widgets. | Error |
| **RK004** | Duplicate Action | Registered Action names conflict or are registered multiple times with inconsistent schemas. | Warning |
| **RK005** | Invalid Binding | Bind syntax key is empty or references an illegal format. | Error |

---

## 3. Environment Validator (`renderkit doctor`)

The CLI-driven validator scans directories before code generation to prevent compiler runtime crashes:

* **Jetpack Compose Compatibility**: Checks `android/app/build.gradle` for `composeOptions { kotlinCompilerExtensionVersion = ... }` and `buildFeatures { compose = true }`.
* **Gradle Toolchain**: Validates minimum Gradle and Android Gradle Plugin versions for Jetpack Compose compilation.
* **Material3 Check**: Scans dependencies block to ensure `androidx.compose.material3:material3` is imported.
* **iOS Deployment Target**: Scans Xcode project configs and `Podfile` to verify deployment target is set to at least `iOS 13.0` (required for SwiftUI).
