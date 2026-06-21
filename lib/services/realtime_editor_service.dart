import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Real-time editor service for WebSocket communication with Visual Helper
/// Cross-platform version (works on Web, macOS, iOS, Android)
class RealtimeEditorService {
  static RealtimeEditorService? _instance;
  static RealtimeEditorService get instance {
    _instance ??= RealtimeEditorService._();
    return _instance!;
  }

  RealtimeEditorService._();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  StreamSubscription? _subscription;

  // Stream controllers for different event types
  final _widgetUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _inspectModeController = StreamController<bool>.broadcast();
  final _navigateController = StreamController<String>.broadcast();
  final _hotReloadController = StreamController<void>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _inspectAtController = StreamController<Map<String, double>>.broadcast();

  // Public streams for listening
  Stream<Map<String, dynamic>> get widgetUpdates => _widgetUpdateController.stream;
  Stream<bool> get inspectModeChanges => _inspectModeController.stream;
  Stream<String> get navigationCommands => _navigateController.stream;
  Stream<void> get hotReloadCommands => _hotReloadController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;
  Stream<Map<String, double>> get inspectAtCommands => _inspectAtController.stream;

  bool get isConnected => _isConnected;

  /// Connect to the editor WebSocket server
  void connect({String host = 'localhost', int port = 8000}) {
    if (_isConnected) {
      debugPrint('[RealtimeEditor] Already connected');
      return;
    }

    try {
      final wsUrl = 'ws://$host:$port/ws/editor';
      debugPrint('[RealtimeEditor] Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _subscription = _channel!.stream.listen(
        (data) {
          if (!_isConnected) {
            debugPrint('[RealtimeEditor] Connected!');
            _isConnected = true;
            _connectionController.add(true);

            // Identify as Flutter client
            _send({
              'client_type': 'flutter',
              'app_id': 'flutter_trips_app'
            });
          }
          _handleMessage(data);
        },
        onError: (error) {
          debugPrint('[RealtimeEditor] Error: $error');
          _isConnected = false;
          _connectionController.add(false);
        },
        onDone: () {
          debugPrint('[RealtimeEditor] Disconnected');
          _isConnected = false;
          _connectionController.add(false);

          // Auto-reconnect after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (!_isConnected) {
              connect(host: host, port: port);
            }
          });
        },
      );

    } catch (e) {
      debugPrint('[RealtimeEditor] Connection error: $e');
    }
  }

  /// Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      // Ignore binary data (e.g., frames from other clients)
      if (data is! String && data is! Map) {
        return; // Skip binary data
      }
      
      final Map<String, dynamic> message = data is String
          ? jsonDecode(data)
          : Map<String, dynamic>.from(data);

      final type = message['type'] as String?;
      debugPrint('[RealtimeEditor] Received: $type');

      switch (type) {
        case 'connected':
          debugPrint('[RealtimeEditor] Server confirmed connection');
          break;

        case 'widget_update':
          // Widget properties were updated in editor
          _widgetUpdateController.add(message['widget'] ?? message);
          break;

        case 'inspect_mode':
          // Toggle inspect mode
          final enabled = message['enabled'] == true;
          _inspectModeController.add(enabled);
          break;

        case 'navigate':
          // Navigate to a route
          final route = message['route'] as String?;
          if (route != null) {
            _navigateController.add(route);
          }
          break;

        case 'command':
          // Handle commands from editor
          final data = message['data'] as Map<String, dynamic>?;
          if (data != null) {
            final command = data['command'] as String?;
            if (command == 'navigate') {
              final page = data['page'] as String?;
              if (page != null) {
                debugPrint('[RealtimeEditor] Navigate command: $page');
                _navigateController.add(page);
              }
            } else if (command == 'inspect_at') {
              final x = (data['x'] as num?)?.toDouble() ?? 0;
              final y = (data['y'] as num?)?.toDouble() ?? 0;
              debugPrint('[RealtimeEditor] Inspect at: ($x, $y)');
              _inspectAtController.add({'x': x, 'y': y});
            }
          }
          break;

        case 'hot_reload':
          // Trigger hot reload (handled by dev tools)
          _hotReloadController.add(null);
          break;

        case 'pong':
          // Heartbeat response
          break;

        default:
          debugPrint('[RealtimeEditor] Unknown message type: $type');
      }
    } catch (e) {
      debugPrint('[RealtimeEditor] Error parsing message: $e');
    }
  }

  /// Send message to server
  void _send(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (e) {
        debugPrint('[RealtimeEditor] Send error: $e');
      }
    }
  }

  /// Send widget selection to editor
  void sendWidgetSelected(Map<String, dynamic> widgetInfo) {
    _send({
      'type': 'widget_selected',
      'widget': widgetInfo,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Send component tree to editor
  void sendComponentTree(List<Map<String, dynamic>> components) {
    _send({
      'type': 'component_tree',
      'components': components,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Send current widget tree to editor
  void sendWidgetTree(List<Map<String, dynamic>> tree) {
    _send({
      'type': 'widget_tree',
      'tree': tree,
    });
  }

  /// Send app state to editor
  void sendAppState(Map<String, dynamic> state) {
    _send({
      'type': 'app_state',
      'state': state,
    });
  }

  /// Send UI frame (screenshot) to editor
  void sendFrame(String base64Image) {
    if (_isConnected && _channel != null) {
      _send({
        'type': 'frame',
        'image': base64Image,
      });
    }
  }

  /// Start heartbeat
  void startHeartbeat() {
    Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected) {
        _send({'type': 'ping'});
      }
    });
  }

  /// Disconnect
  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  /// Dispose
  void dispose() {
    disconnect();
    _widgetUpdateController.close();
    _inspectModeController.close();
    _navigateController.close();
    _hotReloadController.close();
    _connectionController.close();
    _inspectAtController.close();
  }
}
