import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';

class LearningService {
  final ApiClient api;

  LearningService(this.api);

  /// Get today's attendance status
  Future<Map<String, dynamic>> getAttendanceStatus() async {
    try {
      final response = await api.dio.get('/api/learning');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check if location is in range
  Future<Map<String, dynamic>> checkLocation(double lat, double lng) async {
    try {
      // print('📡 Check location: $lat, $lng');

      final response = await api.dio.post(
        '/api/learning/check-location',
        data: {
          'latitude': lat,
          'longitude': lng,
        },
      );

      // print('📥 Response: ${response.statusCode} - ${response.data}');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // print('❌ Check location error: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  /// Submit attendance
  Future<Map<String, dynamic>> submitAttendance(double lat, double lng) async {
    try {
      // print('📡 Submit attendance: $lat, $lng');

      final response = await api.dio.post(
        '/api/learning/attend',
        data: {
          'latitude': lat,
          'longitude': lng,
        },
      );

      // print('📥 Response: ${response.statusCode} - ${response.data}');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // print('❌ Submit attendance error: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  /// Get attendance history
  Future<Map<String, dynamic>> getHistory() async {
    try {
      final response = await api.dio.get('/api/learning/history');

      // print('📥 History response: ${response.data}');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ✨ Helper untuk handle error dari API
  String _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      // Handle error message dari API
      if (data is Map<String, dynamic>) {
        // Cek apakah ada message dari API
        if (data['message'] != null) {
          return data['message'].toString();
        }

        // Cek apakah ada errors (validation errors)
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }

      // Default error berdasarkan status code
      switch (statusCode) {
        case 400:
          return 'Permintaan tidak valid';
        case 401:
          return 'Sesi habis. Silakan login ulang';
        case 403:
          return 'Anda tidak memiliki akses';
        case 404:
          return 'Data tidak ditemukan';
        case 422:
          return data.toString(); // Return raw data untuk debug
        case 500:
          return 'Terjadi kesalahan server';
        default:
          return 'Terjadi kesalahan: $statusCode';
      }
    }

    // Handle error tanpa response (network error, timeout, dll)
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Cek jaringan Anda';
      case DioExceptionType.sendTimeout:
        return 'Gagal mengirim data. Cek jaringan Anda';
      case DioExceptionType.receiveTimeout:
        return 'Gagal menerima data. Cek jaringan Anda';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet';
      case DioExceptionType.badCertificate:
        return 'Sertifikat tidak valid';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
