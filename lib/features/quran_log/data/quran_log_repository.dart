import '../../../core/services/api_client.dart';
import 'quran_log_model.dart';

class QuranLogRepository {
  final ApiClient api;

  QuranLogRepository(this.api);

  Future<void> createLog(Map<String, dynamic> data) async {
    await api.dio.post('/api/quran/logs', data: data);
  }

  Future<List<QuranLog>> getLogs() async {
    final res = await api.dio.get('/api/quran/logs');

    print('RAW RESPONSE: ${res.data}');

    final List list = res.data as List;

    return list.map((e) => QuranLog.fromJson(e)).toList();
  }
}
