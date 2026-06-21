import 'package:flutter/material.dart';
import '../../widgets/back_button.dart';

class SelectModelWidget extends StatelessWidget {
  const SelectModelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final models = ['Camry', 'Corolla', 'Prius', 'RAV4', 'Highlander'];
    
    return Scaffold(
      appBar: AppBar(title: const Text('Выбрать модель')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: models.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(models[index]),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.pop(context, models[index]),
                );
              },
            ),
          ),
          const AppBackButton(),
        ],
      ),
    );
  }
}
