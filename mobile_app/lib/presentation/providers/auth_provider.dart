import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/user_model.dart';
import 'package:mobile_app/data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Beritahu UI untuk show loading spinner

    try {
      _user = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true; // Login Sukses
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners(); // Beritahu UI untuk show error message
      return false; // Login Gagal
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}