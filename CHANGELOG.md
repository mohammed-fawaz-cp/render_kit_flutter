## 1.1.9

* Support native layout generation and compiling for `RenderPositioned`, `RenderSwitch`, and `RenderResponsive` widgets.
* Support map literals parsing in the AST parser for `RenderSwitch` cases.
* Fix `RenderIf` RangeError compilation bugs inside Swift and Kotlin code generators.

## 1.1.8

* Add native Coil `AsyncImage` and SwiftUI image loaders for high-fidelity network and local image rendering on `RenderImage`, `RenderCircleAvatar`, and `RenderContainer`.
* Add transitive `material-icons-extended` dependency to support all Material Icons natively.
* Add custom background and foreground colors to `RenderCircleAvatar`.
* Fix class braces scoping in `widgets.dart`.

## 1.1.7

* Update README.md with comprehensive widget properties table listing all 20 layout, display, control, decoration, and visibility components.

## 1.1.6

* Update README.md with detailed documentation for dynamic screen registration, initialization APIs, and FCM background notification guidelines.

## 1.1.5

* Automatically call `WidgetsFlutterBinding.ensureInitialized()` in `RenderKit.initialize()` to prevent binary messenger platform channel setup crash.

## 1.1.4

* Implement dynamic runtime initializer registration on Android and iOS to solve circular/multi-module compiler dependency limitations.
* Replace Theme.AppCompat resource themes with built-in Android DeviceDefault themes to prevent linking errors.
* Import `activity-compose` library to resolve `setContent` compile errors.

## 1.1.3

* Add Kotlin 2.0 and Compose Compiler Gradle plugin support for `render_kit_flutter` Android compilation.

## 1.1.2

* Specify namespace in `android/build.gradle` for Android Gradle Plugin (AGP) 8.0+ compatibility.

## 1.1.1

* Fix example app `main.dart` code to properly call `RenderKit.initialize` and `RenderKit.registerActions`.

## 1.1.0

* Introduce automated Native Navigation Engine and automated MethodChannel Event Bridge.
* Add pre-built native routing engines (`RenderKitActivity` on Android, `RenderKitViewController` on iOS).
* Expose `RenderKit.initialize()`, `RenderKit.registerActions(...)`, and `RenderKit.navigateTo(...)` APIs.

## 1.0.0

* Initial release of RenderKit: A declarative UI compilation framework that translates custom Dart DSL widgets into native Kotlin Jetpack Compose and Swift SwiftUI source code.
