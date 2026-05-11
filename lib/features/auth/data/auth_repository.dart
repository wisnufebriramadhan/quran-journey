import '../../../core/services/api_client.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiClient api;

  AuthRepository(this.api);

  Future<String> login(String email, String password) async {
    try {
      final response = await api.dio.post(
        '/api/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      final token = data['data']?['token'];

      if (token == null || token.toString().isEmpty) {
        throw data['message'] ?? 'Token tidak ditemukan';
      }

      return token;
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response!.data['message'] != null) {
        throw e.response!.data['message'];
      }

      throw 'Gagal login. Periksa koneksi atau server.';
    }
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

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await api.dio.get('/api/profile');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response!.data['message'] != null) {
        throw e.response!.data['message'];
      }
      throw 'Gagal mengambil profil.';
    }
  }
}
