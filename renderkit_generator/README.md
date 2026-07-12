# renderkit_generator

Code generator package for RenderKit compiling DSL to Compose and SwiftUI.

## Features

This builder package:
- Scans `@RenderEntry` annotations in Dart code.
- Builds intermediate representation (IR) layouts.
- Generates native Jetpack Compose and SwiftUI files.

## Usage

Add `renderkit_generator` and `build_runner` to your `dev_dependencies` in your `pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  renderkit_generator: ^0.1.0
```

Run the build generator command:

```bash
dart run build_runner build
```
