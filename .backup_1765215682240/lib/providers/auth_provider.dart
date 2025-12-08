import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _phoneNumber;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _userName;

  String? get phoneNumber => _phoneNumber;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;

  // Вход по номеру телефона (демо версия)
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Симуляция отправки SMS
    await Future.delayed(const Duration(seconds: 1));

    _phoneNumber = phoneNumber;
    _isLoading = false;
    notifyListeners();
  }

  // Верификация SMS кода (демо версия)
  Future<bool> verifySMSCode(String smsCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Симуляция верификации
    await Future.delayed(const Duration(seconds: 1));
    
    // Принимаем любой 6-значный код
    if (smsCode.length == 6) {
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Неверный код';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Выход
  Future<void> signOut() async {
    _isAuthenticated = false;
    _phoneNumber = null;
    _userName = null;
    notifyListeners();
  }

  // Обновление профиля
  Future<void> updateProfile({
    required String displayName,
    String? photoURL,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _userName = displayName;
    _isLoading = false;
    notifyListeners();
  }
}
