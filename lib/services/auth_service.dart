import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isAdmin = false;

  // Example: Store your token here
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;

  // Call this when you log in and get a token
  void setToken(String token) {
    _token = token;
  }

  Future<void> login({required bool isAdmin}) async {
    _isLoggedIn = true;
    _isAdmin = isAdmin;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _isLoggedIn = false;
    _isAdmin = false;
    notifyListeners();
    
    // Clear navigation stack and return to login
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<Map<String, String>> getAuthHeaders() async {
    // You might want to refresh the token here if needed
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}