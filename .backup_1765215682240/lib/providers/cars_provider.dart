import 'package:flutter/material.dart';

class CarsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cars = [
    {'id': '1', 'mark': 'Toyota', 'model': 'Camry', 'regNumber': 'ABC123'},
    {'id': '2', 'mark': 'Honda', 'model': 'Civic', 'regNumber': 'XYZ789'},
  ];
  
  final List<String> _marks = ['Toyota', 'Honda', 'BMW', 'Mercedes', 'Audi', 'Volkswagen'];
  final List<String> _models = ['Camry', 'Corolla', 'Prius', 'RAV4', 'Highlander'];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get cars => _cars;
  List<String> get marks => _marks;
  List<String> get models => _models;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Добавить машину
  Future<void> addCar({
    required String mark,
    required String model,
    required String regNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _cars.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'mark': mark,
      'model': model,
      'regNumber': regNumber,
    });
    _isLoading = false;
    notifyListeners();
  }

  // Удалить машину
  void deleteCar(String carId) {
    _cars.removeWhere((car) => car['id'] == carId);
    notifyListeners();
  }
}
