class IRWidget {
  final String type;
  final Map<String, dynamic> properties;
  final List<IRWidget> children;

  IRWidget({
    required this.type,
    required this.properties,
    required this.children,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'properties': properties,
        'children': children.map((c) => c.toJson()).toList(),
      };
}

class IRProperty {
  final String type;
  final Map<String, dynamic> properties;

  IRProperty({
    required this.type,
    required this.properties,
  });

  Map<String, dynamic> toJson() => {
        '__type': 'IRProperty',
        'type': type,
        'properties': properties,
      };
}

class IRBinding {
  final String key;
  IRBinding(this.key);

  Map<String, dynamic> toJson() => {
        '__type': 'IRBinding',
        'key': key,
      };
}

class IRAction {
  final String name;
  final Map<String, dynamic> arguments;
  IRAction(this.name, [this.arguments = const {}]);

  Map<String, dynamic> toJson() => {
        '__type': 'IRAction',
        'name': name,
        'arguments': arguments,
      };
}
