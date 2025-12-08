import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TripPage extends StatelessWidget {
  final String tripId;
  const TripPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали поездки')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Маршрут', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    const Text('От: Нью-Йорк'),
                    const Text('До: Бостон'),
                    const SizedBox(height: 12),
                    const Text('Дата: 15 декабря 2025'),
                    const Text('Время: 10:00'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/create-trip'),
              child: const Text('Пересоединиться в Поездку'),
            ),
          ],
        ),
      ),
    );
  }
}
