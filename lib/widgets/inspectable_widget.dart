import 'dart:async';
import 'package:flutter/material.dart';
import '../services/realtime_editor_service.dart';

/// Виджет-обёртка, делающая любой виджет инспектируемым
/// Синхронизирует props через WebSocket
class InspectableWidget extends StatefulWidget {
  final String componentName;
  final String componentPath;
  final Map<String, dynamic> initialProps;
  final Widget Function(BuildContext context, Map<String, dynamic> props) builder;

  const InspectableWidget({
    super.key,
    required this.componentName,
    required this.componentPath,
    required this.initialProps,
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
    _currentProps = Map<String, dynamic>.from(widget.initialProps);
    _componentId = '${widget.componentPath}_${DateTime.now().millisecondsSinceEpoch}';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToUpdates();
    });
  }

  void _listenToUpdates() {
    // Слушаем обновления props от WebSocket
    _subscription = _realtimeService.widgetUpdates.listen((data) {
      final updatePath = data['path'] as String?;
      final updateId = data['id'] as String?;
      
      if (updatePath == widget.componentPath || updateId == _componentId) {
        final newProps = data['props'] as Map<String, dynamic>? ?? 
                         (data is Map<String, dynamic> ? data : {});
        
        if (mounted) {
          setState(() {
            _currentProps = {..._currentProps, ...newProps};
          });
        }
        
        debugPrint('🔄 Props updated for ${widget.componentName}');
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
    
    // Отправляем информацию о выбранном компоненте
    _realtimeService.sendWidgetSelected({
      'id': _componentId,
      'name': widget.componentName,
      'path': widget.componentPath,
      'type': widget.componentName,
      ..._currentProps,
      'bounds': _getBounds(),
    });

    debugPrint('👆 Tapped on ${widget.componentName}');
  }

  @override
  void dispose() {
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
