import 'dart:async';
import 'package:flutter/material.dart';
import '../services/realtime_editor_service.dart';

/// Глобальный реестр компонентов для Component Tree
class ComponentRegistry {
  static final ComponentRegistry _instance = ComponentRegistry._();
  static ComponentRegistry get instance => _instance;
  ComponentRegistry._();

  final Map<String, Map<String, dynamic>> _components = {};
  final _updateController = StreamController<void>.broadcast();
  
  Stream<void> get onUpdate => _updateController.stream;
  List<Map<String, dynamic>> get components => _components.values.toList();

  void register(String id, Map<String, dynamic> info) {
    _components[id] = info;
    _updateController.add(null);
    // Отправляем обновление дерева компонентов
    RealtimeEditorService.instance.sendComponentTree(_components.values.toList());
  }

  void unregister(String id) {
    _components.remove(id);
    _updateController.add(null);
    RealtimeEditorService.instance.sendComponentTree(_components.values.toList());
  }

  void clear() {
    _components.clear();
    _updateController.add(null);
  }

  /// Find component by file path
  Map<String, dynamic>? findByPath(String filePath) {
    return _components.values.firstWhere(
      (c) => c['filePath'] == filePath,
      orElse: () => {},
    );
  }

  /// Update component props
  void updateProps(String id, Map<String, dynamic> newProps) {
    if (_components.containsKey(id)) {
      final current = _components[id]!;
      final currentProps = Map<String, dynamic>.from(current['props'] ?? {});
      currentProps.addAll(newProps);
      _components[id] = {...current, 'props': currentProps};
      _updateController.add(null);
    }
  }
}

/// Виджет-обёртка, делающая любой виджет инспектируемым
/// Синхронизирует props через WebSocket
class InspectableWidget extends StatefulWidget {
  final String componentName;
  final String filePath; // Полный путь к файлу
  final int lineNumber; // Номер строки в файле
  final Map<String, dynamic> editableProps; // Редактируемые свойства
  final Widget Function(BuildContext context, Map<String, dynamic> props) builder;

  const InspectableWidget({
    super.key,
    required this.componentName,
    required this.filePath,
    required this.lineNumber,
    required this.editableProps,
    required this.builder,
  });

  @override
  State<InspectableWidget> createState() => _InspectableWidgetState();
}

class _InspectableWidgetState extends State<InspectableWidget> {
  late Map<String, dynamic> _currentProps;
  late String _componentId;
  final _realtimeService = RealtimeEditorService.instance;
  bool _isSelected = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _currentProps = Map<String, dynamic>.from(widget.editableProps);
    _componentId = '${widget.componentName}_${widget.lineNumber}_${DateTime.now().millisecondsSinceEpoch}';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerComponent();
      _listenToUpdates();
    });
  }

  void _registerComponent() {
    // Регистрируем компонент в глобальном реестре
    ComponentRegistry.instance.register(_componentId, {
      'id': _componentId,
      'name': widget.componentName,
      'filePath': widget.filePath,
      'lineNumber': widget.lineNumber,
      'props': _currentProps,
      'bounds': _getBounds(),
    });
  }

  void _listenToUpdates() {
    // Слушаем обновления props от WebSocket
    _subscription = _realtimeService.widgetUpdates.listen((data) {
      debugPrint('[InspectableWidget] Received update: $data');
      
      final updatePath = data['filePath'] as String?;
      final updateId = data['id'] as String?;
      final updateLine = data['lineNumber'] as int?;
      final componentName = data['name'] as String?;
      
      // Проверяем соответствие по ID, пути файла, имени компонента или номеру строки
      final matchesId = updateId == _componentId;
      final matchesPath = updatePath != null && widget.filePath.contains(updatePath);
      final matchesPathExact = updatePath == widget.filePath;
      final matchesName = componentName == widget.componentName;
      final matchesLine = updatePath == widget.filePath && updateLine == widget.lineNumber;
      
      final matches = matchesId || matchesPathExact || matchesLine || 
                      (matchesPath && matchesName);
      
      debugPrint('[InspectableWidget] Match check - ID: $matchesId, Path: $matchesPath, Name: $matchesName');
      
      if (matches) {
        final newProps = data['props'] as Map<String, dynamic>? ?? {};
        
        if (mounted && newProps.isNotEmpty) {
          debugPrint('[InspectableWidget] Applying props to ${widget.componentName}: $newProps');
          
          setState(() {
            // Merge new props with current props
            for (final entry in newProps.entries) {
              _currentProps[entry.key] = _parseValue(entry.key, entry.value);
            }
          });
          
          // Update in registry
          ComponentRegistry.instance.updateProps(_componentId, _currentProps);
          
          debugPrint('[InspectableWidget] Props applied: $_currentProps');
        }
      }
    });
  }

  /// Parse value based on property name (handle colors, numbers, etc.)
  dynamic _parseValue(String propName, dynamic value) {
    final lowerName = propName.toLowerCase();
    
    // Color parsing
    if (lowerName.contains('color') || lowerName.contains('background')) {
      if (value is String) {
        return _parseColor(value);
      } else if (value is int) {
        return Color(value);
      }
    }
    
    // Number parsing for size properties
    if (lowerName.contains('width') || lowerName.contains('height') ||
        lowerName.contains('size') || lowerName.contains('radius') ||
        lowerName.contains('padding') || lowerName.contains('margin') ||
        lowerName.contains('elevation')) {
      if (value is String) {
        return double.tryParse(value) ?? value;
      }
    }
    
    return value;
  }

  /// Parse color from string (hex or named color)
  Color? _parseColor(String colorStr) {
    // Remove # if present
    String hex = colorStr.replaceAll('#', '').trim();
    
    // Handle different hex formats
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha
    } else if (hex.length == 3) {
      // Expand shorthand (e.g., "F00" -> "FFFF0000")
      hex = 'FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    }
    
    try {
      final colorValue = int.parse(hex, radix: 16);
      return Color(colorValue);
    } catch (e) {
      debugPrint('[InspectableWidget] Failed to parse color: $colorStr');
      // Try named colors
      return _namedColor(colorStr);
    }
  }

  /// Get color by name
  Color? _namedColor(String name) {
    final colors = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'cyan': Colors.cyan,
      'white': Colors.white,
      'black': Colors.black,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'amber': Colors.amber,
      'teal': Colors.teal,
      'indigo': Colors.indigo,
      'deeppurple': Colors.deepPurple,
      'lightblue': Colors.lightBlue,
      'lightgreen': Colors.lightGreen,
    };
    return colors[name.toLowerCase()];
  }

  Map<String, dynamic>? _getBounds() {
    try {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final position = box.localToGlobal(Offset.zero);
        return {
          'x': position.dx,
          'y': position.dy,
          'width': box.size.width,
          'height': box.size.height,
        };
      }
    } catch (e) {
      // Игнорируем ошибки
    }
    return null;
  }

  void _handleTap() {
    setState(() {
      _isSelected = true;
    });
    
    // Отправляем информацию о выбранном компоненте с путём к файлу и строкой
    _realtimeService.sendWidgetSelected({
      'id': _componentId,
      'name': widget.componentName,
      'type': widget.componentName,
      'filePath': widget.filePath,
      'lineNumber': widget.lineNumber,
      'props': _currentProps,
      'bounds': _getBounds(),
    });

    debugPrint('[InspectableWidget] Selected: ${widget.componentName} at ${widget.filePath}:${widget.lineNumber}');
  }

  @override
  void dispose() {
    ComponentRegistry.instance.unregister(_componentId);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childWidget = widget.builder(context, _currentProps);
    
    return GestureDetector(
      onTap: _handleTap,
      child: _isSelected
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: childWidget,
            )
          : childWidget,
    );
  }
}
