import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required this.authService}) {
    _initializeUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await authService.getCurrentUser();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await authService.login(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, String phone, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Don't set current user since registration requires email verification
      await authService.register(name, email, password, phone, role);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await authService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await authService.apiService.updateUserProfile(
        name: name,
        phone: phone,
        address: address,
        profileImage: profileImage,
      );
      _currentUser = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
