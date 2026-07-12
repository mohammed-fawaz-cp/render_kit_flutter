# RenderKit DSL & Runtime Architecture Specification

This document details the declarative widget API design, state binding mechanisms, typed action stream events, and the Flutter Preview renderer.

## 1. Declarative Widgets & Properties

RenderKit avoids arbitrary runtime execution. It defines a highly structured subset of layout and display primitives:

### Shared Property Objects
To ensure clean mapping across Flutter, Jetpack Compose, and SwiftUI, properties use platform-agnostic representations:

- `RenderColor`: 32-bit hex integer representation. Maps to Flutter `Color`, Compose `Color`, SwiftUI `Color`.
- `RenderDimension`: Absolute dp/pixels or percentage sizing.
- `RenderInsets`: Padding values. Maps to `EdgeInsets` (Flutter), `PaddingValues` (Compose), `EdgeInsets` (SwiftUI).
- `RenderTextStyle`: Styling rules (size, color, weight) mapped cleanly to native text rendering engines.

---

## 2. Declarative State Bindings

To bind screen fields to live dynamic data, the compiler uses `RenderBind`:
```dart
RenderText(
  RenderBind("callerName"),
)
```
### Native Resolution Flow
* **Jetpack Compose**: Compiles to `Text(text = state["callerName"].toString())`.
* **SwiftUI**: Compiles to `Text(String(describing: state["callerName"] ?? ""))`.
* **Flutter Preview**: Resolves against `RenderPreviewState.of(context)`.

---

## 3. Typed Actions & Stream Event Pipeline

Callbacks (e.g. `onPressed: () { ... }`) are forbidden as they cannot be cleanly serialized and compiled across codebases. Instead, RenderKit relies on **Typed Actions**:

1. Developer registers action classes extending `RenderAction`:
   ```dart
   class AcceptCallAction extends RenderAction {
     const AcceptCallAction();
     @override
     Map<String, dynamic> toJson() => {'name': 'AcceptCallAction'};
   }
   ```
2. Controls emit events on trigger:
   ```dart
   RenderButton(
     action: AcceptCallAction(),
     text: "Accept",
   )
   ```
3. Native platforms emit action payloads over a stream (`MethodChannel` / Pigeon) to Dart:
   ```dart
   RenderKit.events.listen((event) {
     if (event.action is AcceptCallAction) {
       // Handle accept call
     }
   });
   ```

---

## 4. Flutter Preview (`RenderPreview`)

Allows development in Dart with hot reload support by wrapping entry screens in state contexts:
```dart
RenderPreview(
  state: {
    "callerName": "John Doe",
  },
  child: IncomingCallScreen(),
)
```
The preview injector utilizes Flutter's `InheritedWidget` to bind and update widgets dynamically without running Compose or SwiftUI compilers on every file change.
