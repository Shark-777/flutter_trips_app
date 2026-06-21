import 'package:flutter/material.dart';
import '../../widgets/inspectable_widget.dart';

/// Демо-страница для тестирования InspectableWidget
/// Показывает как использовать систему редактирования виджетов
class InspectableDemoPage extends StatelessWidget {
  const InspectableDemoPage({super.key});

  Color _parseColor(String? hex) {
    if (hex == null) return Colors.black;
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Live Editor Demo'),
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Text - Inspectable
              InspectableWidget(
                componentName: 'WelcomeText',
                filePath: '/Users/shark777/Playwright Agent/flutter_trips_app/lib/screens/demo/inspectable_demo_page.dart',
                lineNumber: 33,
                editableProps: const {
                  'text': 'Добро пожаловать!',
                  'fontSize': 28.0,
                  'fontWeight': 'bold',
                  'color': '#7C3AED',
                },
                builder: (context, props) {
                  return Text(
                    props['text'] ?? 'Welcome',
                    style: TextStyle(
                      fontSize: (props['fontSize'] as num?)?.toDouble() ?? 28,
                      fontWeight: props['fontWeight'] == 'bold' 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      color: _parseColor(props['color'] as String?),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Subtitle - Inspectable
              InspectableWidget(
                componentName: 'SubtitleText',
                filePath: '/Users/shark777/Playwright Agent/flutter_trips_app/lib/screens/demo/inspectable_demo_page.dart',
                lineNumber: 59,
                editableProps: const {
                  'text': 'Кликните на любой элемент для редактирования',
                  'fontSize': 16.0,
                  'color': '#666666',
                },
                builder: (context, props) {
                  return Text(
                    props['text'] ?? '',
                    style: TextStyle(
                      fontSize: (props['fontSize'] as num?)?.toDouble() ?? 16,
                      color: _parseColor(props['color'] as String?),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Card Container - Inspectable
              InspectableWidget(
                componentName: 'InfoCard',
                filePath: '/Users/shark777/Playwright Agent/flutter_trips_app/lib/screens/demo/inspectable_demo_page.dart',
                lineNumber: 81,
                editableProps: const {
                  'backgroundColor': '#F3E8FF',
                  'borderRadius': 16.0,
                  'padding': 20.0,
                },
                builder: (context, props) {
                  return Container(
                    padding: EdgeInsets.all(
                      (props['padding'] as num?)?.toDouble() ?? 20,
                    ),
                    decoration: BoxDecoration(
                      color: _parseColor(props['backgroundColor'] as String?),
                      borderRadius: BorderRadius.circular(
                        (props['borderRadius'] as num?)?.toDouble() ?? 16,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.touch_app, size: 48, color: Color(0xFF7C3AED)),
                        const SizedBox(height: 12),
                        const Text(
                          'Inspect Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Включите Inspect Mode и кликните на элементы',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Action Button - Inspectable
              InspectableWidget(
                componentName: 'ActionButton',
                filePath: '/Users/shark777/Playwright Agent/flutter_trips_app/lib/screens/demo/inspectable_demo_page.dart',
                lineNumber: 128,
                editableProps: const {
                  'text': 'Начать',
                  'backgroundColor': '#7C3AED',
                  'textColor': '#FFFFFF',
                  'borderRadius': 12.0,
                  'height': 56.0,
                },
                builder: (context, props) {
                  return SizedBox(
                    height: (props['height'] as num?)?.toDouble() ?? 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _parseColor(props['backgroundColor'] as String?),
                        foregroundColor: _parseColor(props['textColor'] as String?),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            (props['borderRadius'] as num?)?.toDouble() ?? 12,
                          ),
                        ),
                      ),
                      child: Text(
                        props['text'] ?? 'Button',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: InspectableWidget(
                      componentName: 'StatCard1',
                      filePath: '/Users/shark777/Playwright Agent/flutter_trips_app/lib/screens/demo/inspectable_demo_page.dart',
                      lineNumber: 170,
                      editableProps: const {
                        'value': '128',
                        'label': 'Поездок',
                        'iconColor': '#22C55E',
                      },
                      builder: (context, props) => _buildStatCard(
                        props['value'] ?? '0',
                        props['label'] ?? 'Label',
                        _parseColor(props['iconColor'] as String?),
                        Icons.directions_car,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InspectableWidget(
                      componentName: 'StatCard2',
                      filePath: '/Users/shark777/Playwright Agent/flutter_trips_app/lib/screens/demo/inspectable_demo_page.dart',
                      lineNumber: 188,
                      editableProps: const {
                        'value': '4.9',
                        'label': 'Рейтинг',
                        'iconColor': '#F59E0B',
                      },
                      builder: (context, props) => _buildStatCard(
                        props['value'] ?? '0',
                        props['label'] ?? 'Label',
                        _parseColor(props['iconColor'] as String?),
                        Icons.star,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildStatCard(String value, String label, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
