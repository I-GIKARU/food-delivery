import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService apiService;

  AuthService({required this.apiService});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    try {
      return await apiService.getUserProfile();
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await apiService.login(email, password);
      final token = response['access_token'];
      final user = User.fromJson(response['user']);
      
      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      return user;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<User?> register(String name, String email, String password, String phone, String role) async {
    try {
      final response = await apiService.register(name, email, password, phone, role);
      
      // Don't save token or auto-login - user needs to verify email first
      // Just return the user data for confirmation
      if (response['user'] != null) {
        return User.fromJson(response['user']);
      }
      
      return null;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
