# RenderKit: Cross-Platform UI Compiler Framework 🚀

RenderKit is a brand-new, open-source cross-platform UI compilation framework. Unlike React Native or Flutter, RenderKit is **not a runtime bridge** and does not draw on its own canvas. Instead, it is a **pure compile-time toolchain** that translates a declarative Dart DSL directly into highly optimized, idiomatic native source code:
* **Jetpack Compose (Kotlin)** for Android
* **SwiftUI (Swift)** for iOS

It also includes a high-fidelity **Flutter Preview Renderer** to support fast hot-reload development without needing to compile native projects on every save.

---

## 📖 Table of Contents
1. [Why RenderKit?](#-why-renderkit)
2. [Package Monorepo Architecture](#-package-monorepo-architecture)
3. [Quick Start Guide](#-quick-start-guide)
   * [Step 1: Install Dependencies](#step-1-install-dependencies)
   * [Step 2: Create a Declarative UI](#step-2-create-a-declarative-ui)
   * [Step 3: Run the Compiler](#step-3-run-the-compiler)
   * [Step 4: Preview in Flutter](#step-4-preview-in-flutter)
4. [Event & Stream Pipeline](#-event--stream-pipeline)
5. [Diagnostics & Validator (RenderKit Doctor)](#-diagnostics--validator-renderkit-doctor)
6. [Supported Widgets](#-supported-widgets)
7. [Contributing Guide](#-contributing-guide)

---

## 💡 Why RenderKit?

Traditional cross-platform frameworks introduce VM bridges, complex threading pipelines, or custom runtime canvases. RenderKit shifts all this complexity to **compile time**:

* **Zero VM Overhead**: Generated Kotlin and Swift compile directly to native arm64 machine instructions.
* **100% Native Elements**: A `RenderText` compiles to `androidx.compose.material3.Text` on Android and `SwiftUI.Text` on iOS.
* **Declarative State & Actions**: Strict static bindings avoid arbitrary Dart execution, producing highly performant, deterministic UIs.

---

## 📦 Package Monorepo Architecture

The workspace consists of specialized packages structured for modularity and easy integration:

* **`renderkit_annotations`**: Defines the lightweight `@RenderEntry()` annotations.
* **`renderkit`**: Contains the core widget DSL (`RenderColumn`, `RenderText`, etc.) and the state-injector `RenderPreview` component.
* **`renderkit_generator`**: The compiler frontend containing the AST Parser, Diagnostic Engine, and code generators.
* **`renderkit_cli`**: CLI binary supporting diagnostic verification (`doctor`), compiling, and project setup.

---

## ⚡ Quick Start Guide

### Step 1: Install Dependencies
Add the dependencies to your application's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  render_kit_flutter:
    path: path/to/render_kit

dev_dependencies:
  build_runner: ^2.4.0
  renderkit_generator:
    path: path/to/render_kit/renderkit_generator
```

### Step 2: Create a Declarative UI
Define a screen in `lib/incoming_call_screen.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:render_kit_flutter/render_kit.dart';

// Declare Event Actions
class AcceptCallAction extends RenderAction {
  const AcceptCallAction();
  @override
  Map<String, dynamic> toJson() => {'name': 'AcceptCallAction'};
}

class RejectCallAction extends RenderAction {
  const RejectCallAction();
  @override
  Map<String, dynamic> toJson() => {'name': 'RejectCallAction'};
}

// Annotate entry points for compile time compilation
@RenderEntry()
class IncomingCallScreen extends RenderWidget {
  const IncomingCallScreen();

  @override
  RenderWidget build(BuildContext context) {
    return RenderCenter(
      child: RenderCard(
        child: RenderPadding(
          padding: const RenderInsets.all(24.0),
          child: RenderColumn(
            children: [
              const RenderCircleAvatar(radius: 40.0),
              const RenderSpacer(),
              const RenderText(
                RenderBind<String>("callerName"),
                style: RenderTextStyle(fontSize: 24.0, bold: true),
              ),
              const RenderSpacer(),
              RenderRow(
                children: [
                  RenderButton(
                    action: const AcceptCallAction(),
                    text: "Accept",
                  ),
                  const RenderSpacer(),
                  RenderButton(
                    action: const RejectCallAction(),
                    text: "Reject",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Step 3: Run the Compiler
Compile the Dart DSL code to native Kotlin Jetpack Compose and SwiftUI files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
* `lib/incoming_call_screen.compose.kt`
* `lib/incoming_call_screen.swift`

### Step 4: Preview in Flutter
Instantiate the widget inside your Flutter app using the preview wrapper:

```dart
import 'package:flutter/material.dart';
import 'package:render_kit_flutter/render_kit.dart';
import 'incoming_call_screen.dart';

class PreviewContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 320,
          height: 350,
          child: const RenderPreview(
            state: {
              'callerName': 'John Doe',
            },
            child: IncomingCallScreen(),
          ),
        ),
      ),
    );
  }
}
```

---

## 🔄 Event & Stream Pipeline

Rather than passing dynamic, non-serializable callbacks, RenderKit operates on a unified broadcast stream:

1. **Emit**: When a user clicks a button on Flutter Preview, iOS, or Android, it emits a structured Action.
2. **Listen**: In your Dart application, listen to the stream to trigger business logic:
```dart
RenderKit.events.listen((event) {
  if (event.action is AcceptCallAction) {
    print('Connecting call...');
  }
});
```
3. **Rebuild**: You can wrap widgets in a `RenderEventListener` to reactively rebuild elements when events are fired:
```dart
RenderEventListener(
  builder: (context, lastEvent) {
    return Text(lastEvent != null ? 'Last Event: ${lastEvent.action.runtimeType}' : 'Idle');
  },
)
```


---

## 🛠️ CLI Toolchain & Commands

RenderKit includes a dedicated CLI (`renderkit_cli`) to manage compilation pipelines, setup configurations, run environment diagnostics, and start preview engines.

To run the CLI commands, ensure `renderkit_cli` is added to your project's `dev_dependencies`:
```bash
dart run renderkit_cli <command> [arguments]
```

### Commands

* **`configure`**: Automatically creates the `build.yaml` file needed for the generator toolchain.
  ```bash
  dart run renderkit_cli configure
  ```
* **`install`**: Installs compiler core configurations and verifies package dependencies.
  ```bash
  dart run renderkit_cli install
  ```
* **`doctor`**: Runs environment verification checks to ensure native folders are ready for Jetpack Compose and SwiftUI.
  ```bash
  dart run renderkit_cli doctor
  ```
  
  ##### Manual Android Gradle Configuration
  If the doctor check flags errors or if you need to configure Jetpack Compose manually:
  
  * **Groovy DSL (`android/app/build.gradle`)**:
    ```groovy
    android {
        buildFeatures { compose true }
        composeOptions { kotlinCompilerExtensionVersion '1.5.0' }
    }
    dependencies {
        implementation 'androidx.compose.material3:material3:1.1.0'
    }
    ```
    
  * **Kotlin DSL (`android/app/build.gradle.kts`)**:
    ```kotlin
    android {
        buildFeatures { compose = true }
        composeOptions { kotlinCompilerExtensionVersion = "1.5.0" }
    }
    dependencies {
        implementation("androidx.compose.material3:material3:1.1.0")
    }
    ```
* **`generate`**: Manually triggers the compiler to parse `@RenderEntry` widgets and output native `.compose.kt` and `.swift` files.
  ```bash
  dart run renderkit_cli generate
  ```
* **`preview`**: Launches the live Flutter preview engine for hot-reloading widget layouts.
  ```bash
  dart run renderkit_cli preview
  ```
* **`validate`**: Runs schema validation checks to discover broken bindings or duplicate actions.
  ```bash
  dart run renderkit_cli validate
  ```
* **`clean`**: Cleans up compiler caches and generated output assets.
  ```bash
  dart run renderkit_cli clean
  ```

For detailed specifications, see [cli.md](file:///e:/projects/flutter/plugins/renderkit/render_kit/docs/cli.md).

---

## 🏥 Diagnostics & Validator (RenderKit Doctor)

To prevent native compilation crashes, RenderKit incorporates static diagnostics and environment verifications:

### Compiler Error Codes
* **`RK001` (Unknown Widget)**: Triggers if you try to render unsupported widgets.
* **`RK002` (Unknown Property)**: Triggers if a constructor argument is unrecognized or invalid.
* **`RK003` (Unsupported Expression)**: Occurs if you write custom dynamic Dart functions inside the `build` method (which cannot be compiled to Swift/Kotlin).

### Running Environment Checks
Check if your native Android and iOS folders support the required Jetpack Compose and SwiftUI modules:

```bash
# Run from the root of your project
dart run renderkit_cli doctor
```

---

## 🎨 Supported Widgets (v1 Initial Release)

* **Layouts**: `RenderColumn`, `RenderRow`, `RenderStack`, `RenderContainer`, `RenderPadding`, `RenderSpacer`, `RenderExpanded`, `RenderAlign`, `RenderCenter`, `RenderPositioned`
* **Displays**: `RenderText`, `RenderImage`, `RenderIcon`, `RenderDivider`
* **Controls**: `RenderButton`, `RenderIconButton`
* **Decorations**: `RenderCard`, `RenderCircleAvatar`
* **Visibility / Conditions**: `RenderVisibility`, `RenderIf`, `RenderSwitch`, `RenderResponsive`

---

## 🤝 Contributing Guide

We welcome contributions to make the cross-platform UI compiler ecosystem better!

1. **Fork the Repository**: Clone the code to your local setup.
2. **Configure Workspaces**: Run `flutter pub get` in the root folder to link all subpackages.
3. **Write Tests**: Ensure any widget additions include:
   * A mapping parser unit test in `renderkit_generator`.
   * A Compose code generation snapshot.
   * A SwiftUI code generation snapshot.
4. **Submit a PR**: Describe your feature, the compiler diagnostics written, and test logs.
