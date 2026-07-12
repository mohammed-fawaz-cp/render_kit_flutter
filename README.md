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
4. [Native Platform Setup](#-native-platform-setup)
   * [Android (Jetpack Compose & Material 3)](#-android-jetpack-compose--material-3)
   * [iOS (SwiftUI iOS 13+ Target)](#-ios-swiftui-ios-13-target)
   * [Integrating Generated Native Code](#-integrating-generated-native-code)
5. [Event & Stream Pipeline](#-event--stream-pipeline)
6. [CLI Toolchain & Commands](#-cli-toolchain--commands)
7. [Supported Widgets](#-supported-widgets)
8. [Contributing Guide](#-contributing-guide)

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

## 📱 Native Platform Setup

Before building your application for Android or iOS, the native project files must be configured to support rendering RenderKit's native components (Jetpack Compose for Android and SwiftUI for iOS).

### 🤖 Android (Jetpack Compose & Material 3)

By default, standard Flutter apps do not have Jetpack Compose enabled. You must enable it in your Android build configuration.

#### 1. Enabling Jetpack Compose (Kotlin 2.0+ vs Kotlin 1.x)

Depending on your project's Kotlin version, use one of the following configurations:

##### For Kotlin 2.0+ (Modern Flutter Projects)
Starting in Kotlin 2.0, Jetpack Compose requires the official **Compose Compiler Gradle plugin** instead of `composeOptions`.

1. Open your project-level `android/build.gradle.kts` (or `android/build.gradle`) and add the Compose Compiler plugin to the `plugins` block:
   ```kotlin
   plugins {
       // ... existing plugins
       id("org.jetbrains.kotlin.plugin.compose") version "2.0.0" apply false // Match your Kotlin version
   }
   ```
2. Open your app-level `android/app/build.gradle.kts` (or `android/app/build.gradle`), apply the plugin at the top, and enable Compose:
   ```kotlin
   plugins {
       // ... existing plugins
       id("org.jetbrains.kotlin.plugin.compose")
   }

   android {
       // ... existing configurations
       buildFeatures {
           compose = true
       }
   }
   ```

##### For Kotlin 1.x (Older Flutter Projects)
Open your app-level `android/app/build.gradle` (or `android/app/build.gradle.kts`) and add:
```groovy
android {
    // ... existing configurations
    buildFeatures {
        compose true // (use compose = true in .kts)
    }
    composeOptions {
        // Must match your project's Kotlin compiler compatibility
        kotlinCompilerExtensionVersion '1.5.0' // (use = "1.5.0" in .kts)
    }
}
```

#### 2. Adding Material 3 & Compose Dependencies
Add the Material 3 dependency inside the `dependencies { ... }` block in `android/app/build.gradle` (or `.kts`):
```groovy
dependencies {
    // ... existing dependencies
    implementation 'androidx.compose.material3:material3:1.1.0' // (use implementation(...) in .kts)
}
```

---

### 🍎 iOS (SwiftUI iOS 13+ Target)

SwiftUI requires a minimum deployment target of **iOS 13.0** or later.

1. Open `ios/Podfile` and verify/update the platform version constraint at the top:
   ```ruby
   platform :ios, '13.0'
   ```
2. Open your project in Xcode and update the **Minimum Deployments** target under the target's build settings to `13.0`.

---

### 🔗 Integrating Generated Native Code

When you compile your Dart widgets (via `dart run build_runner build` or `dart run renderkit_cli generate`), RenderKit generates native UI source files inside your Flutter project's `lib/` directory:
- `lib/incoming_call_screen.compose.kt`
- `lib/incoming_call_screen.swift`

Here is how to integrate these generated files into your native build pipelines:

#### Android: Automatic Compilation via SourceSets
Instead of manually copying the generated `.kt` files into your native folders, configure Gradle to treat the Flutter `lib/` folder as a Kotlin source directory:

* **For Kotlin DSL (`android/app/build.gradle.kts`)**:
  Add the following inside the `android { ... }` block:
  ```kotlin
  android {
      // ... existing configurations
      sourceSets {
          getByName("main").java.srcDirs("src/main/java", "../../lib")
      }
  }
  ```
* **For Groovy DSL (`android/app/build.gradle`)**:
  Add the following inside the `android { ... }` block:
  ```groovy
  android {
      // ... existing configurations
      sourceSets {
          main.java.srcDirs += '../../lib'
      }
  }
  ```

#### iOS: Drag & Drop Reference in Xcode
To compile the generated `.swift` files:
1. Open the `ios/` folder of your project in Xcode.
2. Drag and drop the generated Swift files (e.g. `lib/incoming_call_screen.swift`) into the Xcode file navigator under the `Runner` group.
3. In the popup that appears:
   - **Uncheck** "Copy items if needed" (this ensures Xcode references the files in-place, meaning it automatically picks up updates when you re-compile/re-generate).
   - Select **"Create groups"**.
   - Make sure **"Runner"** is checked under **"Add to targets"**.

---

### 🎨 How to Instantiate & Call Generated UI on the Native Side

Once integrated, you can instantiate and render these generated native elements anywhere within your native codebases:

#### 🤖 Android (Kotlin Compose)
The generator produces a standard `@Composable` function named after your annotated Dart class. It accepts a `state` map (to inject current variables) and an `onEvent` callback (to emit actions back to Dart):

```kotlin
import androidx.compose.runtime.*

// Inside your Jetpack Compose activity/view:
YourWidgetName(
    state = mapOf("variableName" to "Value"),
    onEvent = { actionName, args ->
        // Handle action click natively or pipe it back to Flutter
        println("Native clicked Action: $actionName")
    }
)
```

#### 🍎 iOS (SwiftUI)
The generator produces a standard SwiftUI `View` struct. It also accepts a `state` dictionary and an `onEvent` callback:

```swift
import SwiftUI

// Inside your SwiftUI view controller or layout:
struct MyNativeView: View {
    var body: some View {
        YourWidgetName(
            state: ["variableName": "Value"],
            onEvent: { actionName, args in
                // Handle action click natively
                print("Native clicked Action: \(actionName)")
            }
        )
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
