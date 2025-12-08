import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/editor_bridge_service.dart';
import '../services/realtime_editor_service.dart';

/// Enhanced InspectorWrapper that provides real widget inspection
/// Similar to Flutter DevTools Widget Inspector
class InspectorWrapper extends StatefulWidget {
  final Widget child;
  const InspectorWrapper({super.key, required this.child});

  @override
  State<InspectorWrapper> createState() => _InspectorWrapperState();
}

class _InspectorWrapperState extends State<InspectorWrapper> {
  bool _inspectMode = false;
  Offset? _lastTapPosition;
  RenderObject? _selectedRenderObject;
  
  @override
  void initState() {
    super.initState();
    // Listen to inspect mode changes from WebSocket
    EditorBridgeService.realtimeService.inspectModeChanges.listen((enabled) {
      if (mounted) {
        setState(() {
          _inspectMode = enabled;
        });
      }
    });
  }

  /// Extract widget info from a RenderObject
  Map<String, dynamic> _extractWidgetInfo(RenderObject? renderObject, Offset position) {
    if (renderObject == null) {
      return {
        'id': 'unknown_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'Unknown',
        'x': position.dx,
        'y': position.dy,
      };
    }

    // Get the debug creator chain to find widget info
    String widgetType = 'Unknown';
    String? widgetText;
    double? width;
    double? height;
    
    // Try to get widget type from debug info
    final debugCreator = renderObject.debugCreator;
    if (debugCreator != null) {
      final creatorString = debugCreator.toString();
      // Parse widget type from creator string
      final match = RegExp(r'(\w+)(?:\s|$)').firstMatch(creatorString);
      if (match != null) {
        widgetType = match.group(1) ?? 'Unknown';
      }
    }
    
    // Get size if it's a RenderBox
    if (renderObject is RenderBox && renderObject.hasSize) {
      width = renderObject.size.width;
      height = renderObject.size.height;
    }
    
    // Try to find text content for RenderParagraph
    if (renderObject is RenderParagraph) {
      widgetType = 'Text';
      widgetText = renderObject.text.toPlainText();
    }
    
    return {
      'id': 'widget_${renderObject.hashCode}',
      'type': widgetType,
      'text': widgetText,
      'width': width,
      'height': height,
      'x': position.dx,
      'y': position.dy,
      'fontSize': widgetType == 'Text' ? 16 : null,
      'fontWeight': 'normal',
      'color': '#000000',
    };
  }

  /// Find the RenderObject at a given position
  RenderObject? _hitTest(Offset position) {
    final RenderObject? rootRenderObject = context.findRenderObject();
    if (rootRenderObject == null) return null;
    
    RenderObject? result;
    
    void visitor(RenderObject child) {
      if (child is RenderBox) {
        final transform = child.getTransformTo(rootRenderObject);
        final localPosition = MatrixUtils.transformPoint(
          Matrix4.tryInvert(transform) ?? Matrix4.identity(),
          position,
        );
        
        if (child.hitTest(BoxHitTestResult(), position: localPosition)) {
          result = child;
        }
      }
      child.visitChildren(visitor);
    }
    
    rootRenderObject.visitChildren(visitor);
    return result ?? rootRenderObject;
  }

  @override
  Widget build(BuildContext context) {
    // Also listen to postMessage inspect mode
    final inspectEnabled = _inspectMode || EditorBridgeService.inspectModeEnabled;
    
    return Stack(
      children: [
        // The actual app
        Listener(
          onPointerUp: (event) {
            if (inspectEnabled) {
              _lastTapPosition = event.position;
              final renderObject = _hitTest(event.position);
              _selectedRenderObject = renderObject;
              
              final widgetInfo = _extractWidgetInfo(renderObject, event.position);
              EditorBridgeService.sendWidgetInfo(widgetInfo);
            }
          },
          child: widget.child,
        ),
        
        // Inspect mode overlay (optional visual feedback)
        if (inspectEnabled)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Inspect Mode',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
