import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/models/quran_verse.dart';

/// Service untuk download dan cache data Quran ke local storage
class QuranDownloadService {
  static const String _keyDownloaded = 'quran_downloaded';
  static const String _keyVersion = 'quran_version';
  static const String _currentVersion = '1.0';
  static const String baseUrl = 'https://api.quran.com/api/v4';

  /// Cek apakah data Quran sudah di-download
  Future<bool> isQuranDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getBool(_keyDownloaded) ?? false;
    final version = prefs.getString(_keyVersion) ?? '';
    
    return downloaded && version == _currentVersion;
  }

  /// Download seluruh data Quran (604 halaman)
  /// Menggunakan strategi: download per range halaman untuk efisiensi
  Future<void> downloadQuran({
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      onProgress(0.0, 'Memulai download...');
      
      // Download data per batch (setiap 20 halaman = 1 juz approx)
      const int batchSize = 20;
      const int totalPages = 604;
      final int totalBatches = (totalPages / batchSize).ceil();
      
      for (int batch = 0; batch < totalBatches; batch++) {
        final startPage = batch * batchSize + 1;
        final endPage = ((batch + 1) * batchSize).clamp(1, totalPages);
        
        final progress = (batch / totalBatches);
        onProgress(
          progress,
          'Mengunduh halaman $startPage-$endPage dari $totalPages...',
        );
        
        // Download setiap halaman dalam batch ini
        for (int page = startPage; page <= endPage; page++) {
          await _downloadAndCachePage(page);
        }
      }
      
      // Tandai sebagai sudah di-download
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDownloaded, true);
      await prefs.setString(_keyVersion, _currentVersion);
      
      onProgress(1.0, 'Download selesai!');
    } catch (e) {
      throw Exception('Gagal download Quran: $e');
    }
  }

  /// Download single page dan simpan ke SharedPreferences
  Future<void> _downloadAndCachePage(int pageNumber) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/verses/by_page/$pageNumber'
          '?language=ar'
          '&words=false'
          '&fields='
          'text_uthmani,'
          'verse_key,'
          'page_number,'
          'juz_number,'
          'hizb_number',
        ),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        // Simpan response body mentah untuk efisiensi
        await prefs.setString('page_$pageNumber', response.body);
      } else {
        throw Exception('Failed to download page $pageNumber');
      }
    } catch (e) {
      // Ignore error untuk single page, lanjut download page lain
      // print('Error downloading page $pageNumber: $e');
    }
  }

  /// Ambil verses untuk halaman tertentu dari cache lokal
  Future<List<QuranVerse>> getPageFromCache(int pageNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('page_$pageNumber');
      
      if (cachedData == null) {
        return [];
      }

      final data = json.decode(cachedData);
      final List<dynamic> versesJson = data['verses'];
      
      // Gunakan QuranVerse.fromJson() yang sudah ada
      final verses = versesJson
          .map((json) => QuranVerse.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return verses;
    } catch (e) {
      // print('Error reading cache for page $pageNumber: $e');
      return [];
    }
  }

  /// Hapus semua data yang di-download
  Future<void> clearDownloadedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Hapus semua halaman
    for (int page = 1; page <= 604; page++) {
      await prefs.remove('page_$page');
    }
    
    // Hapus flag
    await prefs.remove(_keyDownloaded);
    await prefs.remove(_keyVersion);
  }

  /// Get download size estimate (MB)
  double getEstimatedSizeMB() {
    // Estimasi: ~10-12MB untuk seluruh data Quran (hanya teks Arab)
    return 10.0;
  }

  /// Cek berapa halaman yang sudah di-download
  Future<int> getDownloadedPagesCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    
    for (int page = 1; page <= 604; page++) {
      if (prefs.containsKey('page_$page')) {
        count++;
      }
    }
    
    return count;
  }
}