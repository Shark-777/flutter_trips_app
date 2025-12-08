import 'package:flutter/material.dart';

class SearchTripPage extends StatelessWidget {
  final String from;
  final String to;

  const SearchTripPage({
    super.key,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Найти поездку')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Поиск: $from → $to'),
                    const SizedBox(height: 8),
                    Text('Найдено 3 поездки', style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.directions_car, color: Color(0xFF7C3AED)),
                      title: Text('$from → $to'),
                      subtitle: Text('Дата: ${DateTime.now().add(Duration(days: index + 1))}'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Присоединились к поездке!')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
