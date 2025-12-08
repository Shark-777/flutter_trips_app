import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поездки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Изображение
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image, size: 80, color: Colors.grey),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Поле "Откуда"
                  TextField(
                    controller: _fromController,
                    decoration: InputDecoration(
                      labelText: 'Откуда (FROM)',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Поле "Куда"
                  TextField(
                    controller: _toController,
                    decoration: InputDecoration(
                      labelText: 'Куда (TO)',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Кнопка поиска
                  ElevatedButton(
                    onPressed: () {
                      context.push(
                        '/search-trip',
                        extra: {
                          'from': _fromController.text,
                          'to': _toController.text,
                        },
                      );
                    },
                    child: const Text('Найти поездку'),
                  ),
                  const SizedBox(height: 32),
                  
                  // Разделитель
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Мои поездки
                  ElevatedButton.icon(
                    onPressed: () => context.go('/my-trips'),
                    icon: const Icon(Icons.directions_car),
                    label: const Text('Мои поездки'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Мои машины
                  ElevatedButton.icon(
                    onPressed: () => context.go('/add-car'),
                    icon: const Icon(Icons.car_rental),
                    label: const Text('Мои машины'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
