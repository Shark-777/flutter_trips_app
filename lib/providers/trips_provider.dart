import 'package:flutter/material.dart';

class TripsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _trips = [
    {'id': '1', 'from': 'Нью-Йорк', 'to': 'Бостон', 'date': '2025-12-15'},
    {'id': '2', 'from': 'Чикаго', 'to': 'Детройт', 'date': '2025-12-20'},
    {'id': '3', 'from': 'Лос-Анджелес', 'to': 'Сан-Диего', 'date': '2025-12-25'},
  ];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get trips => _trips;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Получить все поездки пользователя
  Future<void> fetchUserTrips(String userId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  // Поиск поездок
  Future<void> searchTrips({
    required String from,
    required String to,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _searchResults = [
      {'id': '10', 'from': from, 'to': to, 'date': '2025-12-08'},
      {'id': '11', 'from': from, 'to': to, 'date': '2025-12-09'},
      {'id': '12', 'from': from, 'to': to, 'date': '2025-12-10'},
    ];
    _isLoading = false;
    notifyListeners();
  }

  // Создать поездку
  Future<void> createTrip({
    required String from,
    required String to,
    required String date,
    required String carId,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _trips.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'from': from,
      'to': to,
      'date': date,
      'carId': carId,
    });
    _isLoading = false;
    notifyListeners();
  }

  // Получить детали поездки
  Map<String, dynamic>? getTripDetails(String tripId) {
    return _trips.firstWhere(
      (trip) => trip['id'] == tripId,
      orElse: () => {'id': tripId, 'from': 'Нью-Йорк', 'to': 'Бостон', 'date': '2025-12-15'},
    );
  }
}
