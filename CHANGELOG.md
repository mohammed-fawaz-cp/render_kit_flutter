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
