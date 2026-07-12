# renderkit_annotations

Annotations for the RenderKit cross-platform UI compiler.

## Features

This package provides annotations such as `@RenderEntry` used by the RenderKit code generator (`renderkit_generator`) to identify entry points and DSL definitions that need to be compiled to Jetpack Compose and SwiftUI.

## Usage

Add `renderkit_annotations` as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  renderkit_annotations: ^0.1.0
```

Annotate your widgets with `@RenderEntry`:

```dart
import 'package:renderkit_annotations/renderkit_annotations.dart';

@RenderEntry()
class MyWidget {
  // ...
}
```
