import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isAdmin = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;

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
} 