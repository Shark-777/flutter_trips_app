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
      final updatePath = data['filePath'] as String?;
      final updateId = data['id'] as String?;
      final updateLine = data['lineNumber'] as int?;
      
      // Проверяем соответствие по ID, пути файла или номеру строки
      final matches = updateId == _componentId ||
          (updatePath == widget.filePath && updateLine == widget.lineNumber);
      
      if (matches) {
        final newProps = data['props'] as Map<String, dynamic>? ?? {};
        
        if (mounted && newProps.isNotEmpty) {
          setState(() {
            _currentProps = {..._currentProps, ...newProps};
          });
          debugPrint('🔄 Props updated for ${widget.componentName}: $newProps');
        }
      }
    });
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

    debugPrint('👆 Selected: ${widget.componentName} at ${widget.filePath}:${widget.lineNumber}');
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
