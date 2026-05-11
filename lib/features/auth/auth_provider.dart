import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/api_client.dart';
import 'data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool isLoading = false;
  bool _isInitialized = false; 
  String? token;
  String? userName;

  AuthProvider() : repository = AuthRepository(ApiClient()) {
    _loadToken();
  }

  // =========================
  // INIT
  // =========================
  Future<void> _loadToken() async {
    isLoading = true;
    notifyListeners();

    token = await storage.read(key: 'token');
    userName = await storage.read(key: 'user_name');

    if (token != null && userName == null) {
      // Try to fetch profile if token exists but name is missing
      try {
        final profile = await repository.getProfile();
        userName = profile['name'];
        if (userName != null) {
          await storage.write(key: 'user_name', value: userName);
        }
      } catch (_) {
        // Silently fail if profile fetch fails on start
      }
    }

    isLoading = false;
    _isInitialized = true; 
    notifyListeners();
  }

  bool get isLoggedIn => token != null;
  bool get isInitialized => _isInitialized; 

  // =========================
  // LOGIN
  // =========================
  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      // 1. Login to get token
      token = await repository.login(email, password);
      await storage.write(key: 'token', value: token);
      
      // 2. Fetch profile to get name
      try {
        final profile = await repository.getProfile();
        userName = profile['name'] ?? email.split('@')[0];
      } catch (_) {
        userName = email.split('@')[0];
      }
      
      await storage.write(key: 'user_name', value: userName);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // REGISTER
  // =========================
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await repository.register(name, email, password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    token = null;
    userName = null;
    await storage.delete(key: 'token');
    await storage.delete(key: 'user_name');
    notifyListeners();
  }
}
