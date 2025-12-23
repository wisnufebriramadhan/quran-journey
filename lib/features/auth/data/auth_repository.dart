import '../../../core/services/api_client.dart';

class AuthRepository {
  final ApiClient api;

  AuthRepository(this.api);

  Future<String> login(String email, String password) async {
    final response = await api.dio.post(
      '/api/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return response.data['token'];
  }

  Future<void> register(String name, String email, String password) async {
    await api.dio.post(
      '/api/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }
}
