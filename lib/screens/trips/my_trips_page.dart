import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/back_button.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  @override
  void initState() {
    super.initState();
    // Загрузить поездки пользователя
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<TripsProvider>().fetchUserTrips(userId);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои поездки'),
        elevation: 0,
      ),
      body: Consumer<TripsProvider>(
        builder: (context, tripsProvider, _) {
          if (tripsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tripsProvider.trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Нет поездок',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Создайте новую поездку',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/create-trip'),
                    child: const Text('Создать поездку'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tripsProvider.trips.length,
            itemBuilder: (context, index) {
              final trip = tripsProvider.trips[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.directions_car, color: Color(0xFF7C3AED)),
                  title: Text('${trip['from']} → ${trip['to']}'),
                  subtitle: Text(trip['date']?.toString() ?? 'Дата не указана'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/trip/${trip['id']}',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create-trip'),
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBackButton(),
    );
  }
}
