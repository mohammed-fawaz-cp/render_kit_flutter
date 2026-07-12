# RenderKit Widget API Reference

This document serves as the formal specification for all 20 core widgets in RenderKit v1.

---

## 1. Layout Widgets

### RenderColumn
* **Description**: Lays out its children in a vertical flow.
* **Constructor**: `RenderColumn({ required List<RenderWidget> children, RenderAlignment alignment })`
* **Properties**:
  - `children`: List of child widgets (Default: `[]`).
  - `alignment`: Layout alignment (Default: `RenderAlignment.topCenter`).
* **Mappings**:
  - **Flutter**: `Column(mainAxisAlignment: MainAxisAlignment.start, children: ...)`
  - **Compose**: `Column(modifier = Modifier.fillMaxWidth()) { ... }`
  - **SwiftUI**: `VStack { ... }`
* **Validation Rules**: Must not contain infinite circular references.

### RenderRow
* **Description**: Lays out its children in a horizontal flow.
* **Constructor**: `RenderRow({ required List<RenderWidget> children, RenderAlignment alignment })`
* **Properties**:
  - `children`: List of child widgets (Default: `[]`).
  - `alignment`: Layout alignment (Default: `RenderAlignment.centerLeft`).
* **Mappings**:
  - **Flutter**: `Row(mainAxisAlignment: MainAxisAlignment.start, children: ...)`
  - **Compose**: `Row(modifier = Modifier.fillMaxWidth()) { ... }`
  - **SwiftUI**: `HStack { ... }`

### RenderStack
* **Description**: Overlays children on top of each other.
* **Constructor**: `RenderStack({ required List<RenderWidget> children })`
* **Mappings**:
  - **Flutter**: `Stack(children: ...)`
  - **Compose**: `Box { ... }`
  - **SwiftUI**: `ZStack { ... }`

### RenderContainer
* **Description**: A convenience box widget for constraints, dimensions, and decorations.
* **Constructor**: `RenderContainer({ RenderWidget? child, RenderDecoration? decoration, RenderConstraints? constraints, dynamic width, dynamic height })`
* **Mappings**:
  - **Flutter**: `Container(width: width, height: height, decoration: decoration, child: child)`
  - **Compose**: `Box(modifier = Modifier.width(w.dp).height(h.dp).background(...)) { ... }`
  - **SwiftUI**: `child.frame(width: w, height: h).background(...)`

### RenderPadding
* **Description**: Insets its child by a given padding.
* **Constructor**: `RenderPadding({ required RenderInsets padding, required RenderWidget child })`
* **Mappings**:
  - **Flutter**: `Padding(padding: padding, child: child)`
  - **Compose**: `Box(modifier = Modifier.padding(...)) { child }`
  - **SwiftUI**: `child.padding(...)`

### RenderSpacer
* **Description**: Creates an adjustable empty space that expands to fill remaining space in a flex layout.
* **Constructor**: `RenderSpacer()`
* **Mappings**:
  - **Flutter**: `Spacer()`
  - **Compose**: `Spacer(modifier = Modifier.weight(1f))`
  - **SwiftUI**: `Spacer()`

### RenderExpanded
* **Description**: Expands a child of a Row or Column to fill the available space.
* **Constructor**: `RenderExpanded({ required RenderWidget child, int flex })`
* **Mappings**:
  - **Flutter**: `Expanded(flex: flex, child: child)`
  - **Compose**: `Box(modifier = Modifier.weight(flex.toFloat())) { child }`
  - **SwiftUI**: `child` (wrapped in generic group or handled by stack spacing)

### RenderAlign
* **Description**: Aligns a child within itself.
* **Constructor**: `RenderAlign({ required RenderAlignment alignment, required RenderWidget child })`
* **Mappings**:
  - **Flutter**: `Align(alignment: alignment, child: child)`
  - **Compose**: `Box(contentAlignment = Alignment.X) { child }`
  - **SwiftUI**: `child.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .X)`

### RenderCenter
* **Description**: Centers its child widget.
* **Constructor**: `RenderCenter({ required RenderWidget child })`
* **Mappings**:
  - **Flutter**: `Center(child: child)`
  - **Compose**: `Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) { child }`
  - **SwiftUI**: `VStack { Spacer(); child; Spacer() }`

### RenderPositioned
* **Description**: Positions a child widget inside a Stack.
* **Constructor**: `RenderPositioned({ required RenderWidget child, double? left, double? top, double? right, double? bottom })`
* **Mappings**:
  - **Flutter**: `Positioned(left: left, top: top, right: right, bottom: bottom, child: child)`
  - **Compose**: `Box(modifier = Modifier.absoluteOffset(x.dp, y.dp)) { child }`
  - **SwiftUI**: `child.offset(x: left, y: top)`

---

## 2. Display Widgets

### RenderText
* **Description**: Displays a string of text.
* **Constructor**: `RenderText(dynamic text, { RenderTextStyle? style })`
* **Mappings**:
  - **Flutter**: `Text(text, style: style)`
  - **Compose**: `Text(text = text, style = style)`
  - **SwiftUI**: `Text(text)`

### RenderImage
* **Description**: Displays an image from network or asset.
* **Constructor**: `RenderImage(dynamic source)`
* **Mappings**:
  - **Flutter**: `Image.network(source)` / `Image.asset(source)`
  - **Compose**: `AsyncImage(model = source)` / `Image(...)`
  - **SwiftUI**: `AsyncImage(url: URL(string: source))`

### RenderIcon
* **Description**: Renders a vector system icon.
* **Constructor**: `RenderIcon(String name, { RenderColor? color, double? size })`
* **Mappings**:
  - **Flutter**: `Icon(icons[name], color: color, size: size)`
  - **Compose**: `Icon(imageVector = Icons.Default.X, contentDescription = name)`
  - **SwiftUI**: `Image(systemName: name)`

### RenderDivider
* **Description**: A thin horizontal line separating content.
* **Constructor**: `RenderDivider({ RenderColor? color, double thickness })`
* **Mappings**:
  - **Flutter**: `Divider(color: color, thickness: thickness)`
  - **Compose**: `HorizontalDivider(color: color, thickness: thickness)`
  - **SwiftUI**: `Divider()`

---

## 3. Control Widgets

### RenderButton
* **Description**: A clickable button emitting an action event.
* **Constructor**: `RenderButton({ required RenderAction action, RenderWidget? child, dynamic text })`
* **Mappings**:
  - **Flutter**: `ElevatedButton(onPressed: emitEvent, child: Text(text))`
  - **Compose**: `Button(onClick = { onEvent(actionName, ...) }) { Text(...) }`
  - **SwiftUI**: `Button(action: { onEvent(...) }) { Text(...) }`

### RenderIconButton
* **Description**: An icon that acts as a clickable button.
* **Constructor**: `RenderIconButton({ required RenderAction action, required RenderIcon icon })`
* **Mappings**:
  - **Flutter**: `IconButton(icon: icon, onPressed: emitEvent)`
  - **Compose**: `IconButton(onClick = { onEvent(...) }) { Icon(...) }`
  - **SwiftUI**: `Button(action: { onEvent(...) }) { Image(...) }`

---

## 4. Decoration & Styling Widgets

### RenderCard
* **Description**: A container with corner rounding and drop shadow elevation.
* **Constructor**: `RenderCard({ required RenderWidget child, RenderDecoration? decoration })`
* **Mappings**:
  - **Flutter**: `Container(decoration: shadowDecoration, child: child)`
  - **Compose**: `Card(modifier = Modifier.fillMaxWidth()) { child }`
  - **SwiftUI**: `VStack { child }.background(Color.white).cornerRadius(8).shadow(radius: 4)`

### RenderCircleAvatar
* **Description**: A circular image avatar or placeholder.
* **Constructor**: `RenderCircleAvatar({ dynamic backgroundImage, double radius })`
* **Mappings**:
  - **Flutter**: `CircleAvatar(backgroundImage: ..., radius: radius)`
  - **Compose**: `Box(modifier = Modifier.size(radius*2).clip(CircleShape)) { ... }`
  - **SwiftUI**: `Text("...").frame(width: radius*2, height: radius*2).clipShape(Circle())`

---

## 5. Visibility & Conditionals

### RenderVisibility
* **Description**: Conditionally controls the visibility of a widget.
* **Constructor**: `RenderVisibility({ required dynamic visible, required RenderWidget child })`
* **Mappings**:
  - **Flutter**: `Visibility(visible: visible, child: child)`
  - **Compose**: `if (visible) { child }`
  - **SwiftUI**: `if visible { child }`

### RenderIf
* **Description**: Declares simple binary conditional rendering without arbitrary Dart expressions.
* **Constructor**: `RenderIf({ required dynamic condition, required RenderWidget trueChild, required RenderWidget falseChild })`
* **Mappings**:
  - **Flutter**: `condition ? trueChild : falseChild`
  - **Compose**: `if (condition) { trueChild } else { falseChild }`
  - **SwiftUI**: `if condition { trueChild } else { falseChild }`

### RenderSwitch
* **Description**: Chooses one widget from a map based on a key value.
* **Constructor**: `RenderSwitch({ required dynamic value, required Map<String, RenderWidget> cases, required RenderWidget defaultChild })`
* **Mappings**:
  - **Flutter**: `cases[value] ?? defaultChild`
  - **Compose**: `switch(value) { case ... }`
  - **SwiftUI**: `switch value { case ... }`

### RenderResponsive
* **Description**: Responsive container offering layouts for mobile, tablet, and desktop bounds.
* **Constructor**: `RenderResponsive({ required RenderWidget mobile, RenderWidget? tablet, RenderWidget? desktop })`
* **Mappings**:
  - **Flutter**: `LayoutBuilder(builder: (c, constraints) => ...)`
  - **Compose**: `BoxWithConstraints { ... }`
  - **SwiftUI**: `GeometryReader { ... }`
