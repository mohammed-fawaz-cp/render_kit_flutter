## 0.1.4

* Support code generation for `RenderPositioned`, `RenderSwitch`, and `RenderResponsive`.
* Support map literals parsing in the AST parser.
* Fix `RenderIf` RangeError compilation bugs inside Swift and Kotlin code generators.

## 0.1.3

* Add high-fidelity native image loaders using Coil AsyncImage (Compose) and SwiftUI AsyncImage.
* Generate layout and icon imports for generated Compose views.
* Map RenderDivider to native Compose Divider components.

## 0.1.2

* Aggregate code compilation output for multiple `@RenderEntry()` widgets inside a single Dart source file to prevent duplicate writes / InvalidOutputException build failures.

## 0.1.1

* Add `com.renderkit.generated` package header to generated Compose Kotlin files.

## 0.1.0

* Initial release of `renderkit_generator`.
* Implement builder and code generation from RenderKit DSL to native Compose and SwiftUI.
