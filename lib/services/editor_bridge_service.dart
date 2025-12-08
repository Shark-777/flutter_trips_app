import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'realtime_editor_service.dart';

/// Сервис для связи с Flutter Visual Helper редактором
/// Cross-platform version (works on Web, macOS, iOS, Android)
/// Использует WebSocket для real-time sync
class EditorBridgeService {
  static GoRouter? _router;
  static bool _initialized = false;
  static bool inspectModeEnabled = false;
  static final RealtimeEditorService _realtimeService = RealtimeEditorService.instance;

  /// Инициализация сервиса с роутером
  static void init(GoRouter router) {
    if (_initialized) return;

    _router = router;
    _initialized = true;

    // Connect to WebSocket for real-time sync
    _realtimeService.connect();
    _realtimeService.startHeartbeat();

    // Listen to WebSocket events
    _realtimeService.inspectModeChanges.listen((enabled) {
      inspectModeEnabled = enabled;
      debugPrint('[EditorBridge] Inspect mode via WS: $enabled');
    });

    _realtimeService.navigationCommands.listen((route) {
      _navigateTo(route);
    });

    _realtimeService.widgetUpdates.listen((widgetData) {
      debugPrint('[EditorBridge] Widget update received: $widgetData');
      // Here you would update widget properties dynamically
      // This requires a state management solution
    });

    debugPrint('[EditorBridge] Flutter service initialized with WebSocket');
  }

  /// Обработка сообщений от редактора
  static void _handleMessage(dynamic data) {
    try {
      if (data is Map || data is String) {
        // Если пришла строка JSON
        final map = data is String ? jsonDecode(data) : data;

        if (map['type'] == 'navigate') {
          final route = map['route'] as String?;
          if (route != null) {
            _navigateTo(route);
          }
        } else if (map['type'] == 'inspect') {
          inspectModeEnabled = map['enabled'] == true;
          debugPrint('[EditorBridge] Inspect mode: $inspectModeEnabled');
        }
      }
    } catch (e) {
      debugPrint('[EditorBridge] Error handling message: $e');
    }
  }

  /// Выполнить навигацию
  static void _navigateTo(String route) {
    if (_router != null) {
      debugPrint('[EditorBridge] Navigating to: $route');
      // GoRouter ожидает путь, например /home
      try {
        _router!.go(route);
      } catch (e) {
        debugPrint('[EditorBridge] Navigation error: $e');
      }
    }
  }

  /// Отправить информацию о выбранном виджете в редактор
  static void sendWidgetInfo(Map<String, dynamic> widgetInfo) {
    // Send via WebSocket
    _realtimeService.sendWidgetSelected(widgetInfo);

    debugPrint('[EditorBridge] Widget info sent: ${widgetInfo['type']}');
  }

  /// Get realtime service for StreamBuilder usage
  static RealtimeEditorService get realtimeService => _realtimeService;
}
