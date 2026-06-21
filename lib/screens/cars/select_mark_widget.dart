import 'package:flutter/material.dart';
import '../../widgets/back_button.dart';

class SelectMarkWidget extends StatelessWidget {
  const SelectMarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final marks = ['Toyota', 'Honda', 'BMW', 'Mercedes', 'Audi', 'Volkswagen'];
    
    return Scaffold(
      appBar: AppBar(title: const Text('Выбрать марку')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: marks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(marks[index]),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.pop(context, marks[index]),
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
