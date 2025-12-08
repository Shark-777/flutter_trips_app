import 'package:flutter/foundation.dart';
import '../../models/component_metadata.dart';

/// Сервис для управления деревом компонентов
/// Хранит метаданные всех компонентов в приложении
class ComponentTreeService extends ChangeNotifier {
  final Map<String, ComponentMetadata> _components = {};
  ComponentMetadata? _rootComponent;
  ComponentMetadata? _selectedComponent;
  int _idCounter = 0;

  ComponentMetadata? get selectedComponent => _selectedComponent;
  ComponentMetadata? get rootComponent => _rootComponent;
  Map<String, ComponentMetadata> get allComponents => Map.unmodifiable(_components);

  /// Генерация уникального ID
  String _generateId() => 'component_${_idCounter++}_${DateTime.now().millisecondsSinceEpoch}';

  /// Регистрация нового компонента в дереве
  String registerComponent({
    required String name,
    required String path,
    required Map<String, dynamic> props,
    ComponentBounds? bounds,
    String? parentId,
  }) {
    final id = _generateId();
    final component = ComponentMetadata(
      id: id,
      name: name,
      path: path,
      props: props,
      bounds: bounds,
      parentId: parentId,
    );

    _components[id] = component;

    // Если это первый компонент - делаем его root
    if (_rootComponent == null && parentId == null) {
      _rootComponent = component;
    }

    // Добавляем в children родителя
    if (parentId != null && _components.containsKey(parentId)) {
      final parent = _components[parentId]!;
      final updatedChildren = List<ComponentMetadata>.from(parent.children)
        ..add(component);
      _components[parentId] = parent.copyWith(children: updatedChildren);
    }

    debugPrint('📦 Registered component: $name (id: $id, path: $path)');
    notifyListeners();
    return id;
  }

  /// Обновление свойств компонента
  void updateComponentProps(String id, Map<String, dynamic> newProps) {
    if (!_components.containsKey(id)) {
      debugPrint('⚠️ Component not found: $id');
      return;
    }

    final component = _components[id]!;
    final updatedProps = {...component.props, ...newProps};
    _components[id] = component.copyWith(props: updatedProps);

    // Обновляем selected если это он
    if (_selectedComponent?.id == id) {
      _selectedComponent = _components[id];
    }

    debugPrint('🔄 Updated props for ${component.name}: $newProps');
    notifyListeners();
  }

  /// Обновление одного свойства компонента
  void updateComponentProp(String id, String propName, dynamic propValue) {
    if (!_components.containsKey(id)) {
      debugPrint('⚠️ Component not found: $id');
      return;
    }

    final component = _components[id]!;
    final updatedProps = {...component.props};
    updatedProps[propName] = propValue;
    _components[id] = component.copyWith(props: updatedProps);

    // Обновляем selected если это он
    if (_selectedComponent?.id == id) {
      _selectedComponent = _components[id];
    }

    debugPrint('🔄 Updated ${component.name}.$propName = $propValue');
    notifyListeners();
  }

  /// Обновление bounds компонента
  void updateComponentBounds(String id, ComponentBounds bounds) {
    if (_components.containsKey(id)) {
      final component = _components[id]!;
      _components[id] = component.copyWith(bounds: bounds);
      notifyListeners();
    }
  }

  /// Поиск компонента по пути
  ComponentMetadata? findComponentByPath(String path) {
    try {
      return _components.values.firstWhere((c) => c.path == path);
    } catch (_) {
      return null;
    }
  }

  /// Поиск компонента по ID
  ComponentMetadata? findComponentById(String id) {
    return _components[id];
  }

  /// Выбор компонента
  void selectComponent(String id) {
    if (_components.containsKey(id)) {
      _selectedComponent = _components[id];
      debugPrint('✅ Selected component: ${_selectedComponent!.name}');
      notifyListeners();
    }
  }

  /// Снятие выбора
  void deselectComponent() {
    _selectedComponent = null;
    debugPrint('❌ Deselected component');
    notifyListeners();
  }

  /// Удаление компонента
  void removeComponent(String id) {
    final component = _components[id];
    if (component == null) return;

    // Удаляем из родителя
    if (component.parentId != null) {
      final parent = _components[component.parentId];
      if (parent != null) {
        final updatedChildren = parent.children
            .where((c) => c.id != id)
            .toList();
        _components[component.parentId!] = parent.copyWith(children: updatedChildren);
      }
    }

    _components.remove(id);
    
    if (_selectedComponent?.id == id) {
      _selectedComponent = null;
    }
    
    debugPrint('🗑️ Removed component: ${component.name}');
    notifyListeners();
  }

  /// Получение полного дерева компонентов
  Map<String, dynamic> getTreeStructure() {
    return {
      'root': _rootComponent?.toJson(),
      'components': _components.values.map((c) => c.toJson()).toList(),
      'selectedId': _selectedComponent?.id,
    };
  }

  /// Очистка всего дерева
  void clear() {
    _components.clear();
    _rootComponent = null;
    _selectedComponent = null;
    _idCounter = 0;
    debugPrint('🧹 Cleared component tree');
    notifyListeners();
  }

  @override
  void dispose() {
    _components.clear();
    super.dispose();
  }
}
