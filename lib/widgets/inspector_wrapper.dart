import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:async';
import '../services/editor_bridge_service.dart';

/// Enhanced InspectorWrapper that provides real widget inspection
/// Similar to Flutter DevTools Widget Inspector
class InspectorWrapper extends StatefulWidget {
  final Widget child;
  const InspectorWrapper({super.key, required this.child});

  @override
  State<InspectorWrapper> createState() => _InspectorWrapperState();
}

class _InspectorWrapperState extends State<InspectorWrapper> {
  final GlobalKey _globalKey = GlobalKey();
  Timer? _frameTimer;
  bool _inspectMode = false;
  bool _isConnected = false;
  Offset? _lastTapPosition;
  RenderObject? _selectedRenderObject;
  
  @override
  void initState() {
    super.initState();
    // Listen to inspect mode changes
    EditorBridgeService.realtimeService.inspectModeChanges.listen((enabled) {
      if (mounted) {
        setState(() {
          _inspectMode = enabled;
          debugPrint('🕵️ InspectorWrapper: Mode changed to $enabled');
        });
      }
    });

    // Listen to connection status
    EditorBridgeService.realtimeService.connectionStatus.listen((connected) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
          if (connected) {
            _startStreaming();
          } else {
            _frameTimer?.cancel();
          }
        });
      }
    });
    
    // Listen to inspect_at commands from editor (remote taps)
    EditorBridgeService.realtimeService.inspectAtCommands.listen((coords) {
      if (mounted) {
        _handleRemoteInspect(coords['x'] ?? 0, coords['y'] ?? 0);
      }
    });
    
    // Check initial status and ALWAYS start streaming after delay
    _isConnected = EditorBridgeService.realtimeService.isConnected;
    if (_isConnected) {
      _startStreaming();
    }
    
    // Force start streaming after 3 seconds (connection may be delayed)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final connected = EditorBridgeService.realtimeService.isConnected;
        debugPrint('🎬 Checking connection after 3s: connected=$connected, _isConnected=$_isConnected');
        if (connected && !_isConnected) {
          debugPrint('🎬 Force starting stream!');
          setState(() {
            _isConnected = true;
          });
          _startStreaming();
        }
      }
    });
    
    // Also try after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _frameTimer == null) {
        debugPrint('🎬 FORCE starting stream at 5s regardless of status');
        setState(() {
          _isConnected = true;
        });
        _startStreaming();
      }
    });
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    super.dispose();
  }

  // Handle remote tap inspection from editor
  void _handleRemoteInspect(double normalizedX, double normalizedY) {
    final RenderObject? rootRenderObject = context.findRenderObject();
    if (rootRenderObject == null || rootRenderObject is! RenderBox) return;
    
    final size = rootRenderObject.size;
    
    // Convert normalized coordinates to actual position
    final actualX = normalizedX * size.width;
    final actualY = normalizedY * size.height;
    final position = Offset(actualX, actualY);
    
    debugPrint('🎯 Remote inspect at: ($actualX, $actualY)');
    
    // Do hit-test at position
    final renderObject = _hitTest(position);
    _selectedRenderObject = renderObject;
    
    // Extract and send widget info
    final widgetInfo = _extractWidgetInfo(renderObject, position);
    EditorBridgeService.sendWidgetInfo(widgetInfo);
    
    debugPrint('🔍 Remote inspected: ${widgetInfo['type']}');
    
    // Show feedback on device
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${widgetInfo['type']}'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _startStreaming() {
    _frameTimer?.cancel();
    // 2-3 FPS to reduce flickering
    _frameTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!_isConnected || !mounted) return;
      try {
        final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;
        
        // Capture image (lower pixelRatio = smaller file = less flicker)
        final image = await boundary.toImage(pixelRatio: 0.5);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final base64String = base64Encode(pngBytes);
          EditorBridgeService.realtimeService.sendFrame(base64String);
        }
      } catch (e) {
        // Ignore capture errors (frame skip)
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
    final inspectEnabled = _inspectMode || EditorBridgeService.inspectModeEnabled;
    
    return RepaintBoundary(
      key: _globalKey,
      child: Stack(
        children: [
          widget.child,
          
          // Inspect overlay
          if (inspectEnabled)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (details) {
                  _lastTapPosition = details.globalPosition;
                  final renderObject = _hitTest(details.globalPosition);
                  _selectedRenderObject = renderObject;
                  
                  final widgetInfo = _extractWidgetInfo(renderObject, details.globalPosition);
                  EditorBridgeService.sendWidgetInfo(widgetInfo);
                  
                  debugPrint('🔍 Inspected: ${widgetInfo['type']}');
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${widgetInfo['type']}'),
                      duration: const Duration(milliseconds: 500),
                    )
                  );
                },
                child: Container(
                  color: Colors.blue.withOpacity(0.1),
                ),
              ),
            ),
            
          // DEBUG STATUS PANEL (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Material(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.wifi : Icons.wifi_off,
                          color: _isConnected ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConnected ? 'WS Connected' : 'WS Disconnected',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Mode: ${inspectEnabled ? "ON" : "OFF"}',
                          style: TextStyle(
                            color: inspectEnabled ? Colors.blue : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _inspectMode = !_inspectMode;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Toggle', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Inspect mode indicator (Top Right)
          if (inspectEnabled)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Tap to Inspect',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
