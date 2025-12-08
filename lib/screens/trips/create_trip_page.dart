import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _dateController = TextEditingController();
  String? _selectedCar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать поездку')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Выберите дату', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Дата поездки',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _dateController.text = date.toString().split(' ')[0];
                  }
                },
              ),
              const SizedBox(height: 24),
              
              Text('Выберите машину', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Выберите машину'),
                value: _selectedCar,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Toyota Camry')),
                  DropdownMenuItem(value: '2', child: Text('Honda Civic')),
                  DropdownMenuItem(value: '3', child: Text('BMW X5')),
                ],
                onChanged: (value) => setState(() => _selectedCar = value),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: () => context.go('/add-car'),
                icon: const Icon(Icons.add),
                label: const Text('Добавить машину'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              
              ElevatedButton(
                onPressed: _selectedCar != null && _dateController.text.isNotEmpty
                    ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Поездка создана!')),
                      );
                      context.pop();
                    }
                    : null,
                child: const Text('Создать поездку'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
}
