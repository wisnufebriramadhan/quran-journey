import 'package:flutter/material.dart';
import '../../core/services/api_client.dart';
import 'data/quran_log_repository.dart';
import 'data/quran_log_model.dart';
import 'package:intl/intl.dart';

class QuranLogProvider extends ChangeNotifier {
  final repo = QuranLogRepository(ApiClient());

  List<QuranLog> logs = [];
  bool loading = false;
  String? error;

  Future<void> fetchLogs() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      logs = await repo.getLogs();
    } catch (e) {
      error = 'Gagal memuat data';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addLog(Map<String, dynamic> data) async {
    if (hasLoggedToday) {
      throw Exception('Bacaan hari ini sudah dicatat');
    }

    await repo.createLog(data);
    await fetchLogs();
  }

  Map<DateTime, List<QuranLog>> get logsByDate {
    final Map<DateTime, List<QuranLog>> map = {};

    for (final log in logs) {
      final date = DateFormat('yyyy-MM-dd').parse(log.date);
      final key = DateTime(date.year, date.month, date.day);

      map.putIfAbsent(key, () => []);
      map[key]!.add(log);
    }

    return map;
  }

  bool get hasLoggedToday {
    final today = DateTime.now();

    return logs.any((log) {
      final logDate = DateTime.parse(log.date);
      return logDate.year == today.year &&
          logDate.month == today.month &&
          logDate.day == today.day;
    });
  }
}
