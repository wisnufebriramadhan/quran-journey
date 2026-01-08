import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/api_client.dart';
import 'data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool isLoading = false;
  String? token;

  AuthProvider() : repository = AuthRepository(ApiClient()) {
    _loadToken();
  }

  // =========================
  // INIT
  // =========================
  Future<void> _loadToken() async {
    token = await storage.read(key: 'token');
    notifyListeners();
  }

  bool get isLoggedIn => token != null;

  // =========================
  // LOGIN
  // =========================
  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await repository.login(email, password);
      token = result;
      await storage.write(key: 'token', value: result);
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
    await storage.delete(key: 'token');
    notifyListeners();
  }
}
