import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthHelper {
  static const _storage = FlutterSecureStorage();

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }
}
