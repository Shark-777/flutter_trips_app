/// Метаданные компонента для Inspector
/// Упрощённая версия без json_serializable для быстрого старта
class ComponentMetadata {
  final String id;
  final String name;
  final String path;
  final Map<String, dynamic> props;
  final ComponentBounds? bounds;
  final List<ComponentMetadata> children;
  final String? parentId;

  ComponentMetadata({
    required this.id,
    required this.name,
    required this.path,
    required this.props,
    this.bounds,
    this.children = const [],
    this.parentId,
  });

  factory ComponentMetadata.fromJson(Map<String, dynamic> json) {
    return ComponentMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      props: Map<String, dynamic>.from(json['props'] ?? {}),
      bounds: json['bounds'] != null 
          ? ComponentBounds.fromJson(json['bounds']) 
          : null,
      children: (json['children'] as List<dynamic>?)
          ?.map((c) => ComponentMetadata.fromJson(c))
          .toList() ?? [],
      parentId: json['parentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'props': props,
    'bounds': bounds?.toJson(),
    'children': children.map((c) => c.toJson()).toList(),
    'parentId': parentId,
  };

  ComponentMetadata copyWith({
    String? id,
    String? name,
    String? path,
    Map<String, dynamic>? props,
    ComponentBounds? bounds,
    List<ComponentMetadata>? children,
    String? parentId,
  }) {
    return ComponentMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      props: props ?? this.props,
      bounds: bounds ?? this.bounds,
      children: children ?? this.children,
      parentId: parentId ?? this.parentId,
    );
  }
}

/// Границы компонента на экране
class ComponentBounds {
  final double x;
  final double y;
  final double width;
  final double height;

  ComponentBounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory ComponentBounds.fromJson(Map<String, dynamic> json) {
    return ComponentBounds(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };
}
