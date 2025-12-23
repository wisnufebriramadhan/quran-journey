import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/api_client.dart';
import 'data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool isLoading = false;

  AuthProvider() : repository = AuthRepository(ApiClient());

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await repository.login(email, password);
      await storage.write(key: 'token', value: token);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}
