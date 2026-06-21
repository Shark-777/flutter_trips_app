import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/back_button.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _markController = TextEditingController();
  final _modelController = TextEditingController();
  final _regController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить машину')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 150,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              
              TextField(
                controller: _markController,
                decoration: InputDecoration(
                  labelText: 'Марка автомобиля',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Модель автомобиля',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _regController,
                decoration: InputDecoration(
                  labelText: 'Регистрационный номер',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Машина добавлена!')),
                  );
                  context.pop();
                },
                child: const Text('Сохранить'),
              ),
              const SizedBox(height: 16),
              const AppBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _markController.dispose();
    _modelController.dispose();
    _regController.dispose();
    super.dispose();
  }
}
