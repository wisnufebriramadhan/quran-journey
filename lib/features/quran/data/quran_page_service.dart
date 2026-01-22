import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/quran_verse.dart';

class QuranPageService {
  static const String baseUrl = 'https://api.quran.com/api/v4';

  /// 🔥 CACHE halaman: pageNumber -> List<QuranVerse>
  final Map<int, List<QuranVerse>> _pageCache = {};

  /// Fetch ayat berdasarkan nomor halaman (1-604)
  Future<List<QuranVerse>> fetchPage(int pageNumber) async {
    // ✅ 1. Jika halaman sudah ada di cache → langsung return
    if (_pageCache.containsKey(pageNumber)) {
      return _pageCache[pageNumber]!;
    }

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
        final data = json.decode(response.body);
        final List verses = data['verses'];

        final result = verses.map((v) => QuranVerse.fromJson(v)).toList();

        // ✅ 2. Simpan ke cache
        _pageCache[pageNumber] = result;

        return result;
      } else {
        throw Exception('Failed to load page $pageNumber');
      }
    } catch (e) {
      throw Exception('Error fetching page $pageNumber: $e');
    }
  }

  /// 🔥 Preload halaman (dipakai saat swipe)
  void preloadPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > 604) return;
    if (_pageCache.containsKey(pageNumber)) return;

    fetchPage(pageNumber);
  }

  /// 🔥 Clear cache (opsional)
  void clearCache() {
    _pageCache.clear();
  }

  /// Get info halaman (surah mana saja yang ada di halaman ini)
  Future<Map<String, dynamic>> getPageInfo(int pageNumber) async {
    final verses = await fetchPage(pageNumber);

    if (verses.isEmpty) return {};

    final firstVerse = verses.first;
    final lastVerse = verses.last;

    return {
      'page': pageNumber,
      'juz': firstVerse.juz,
      'first_verse': '${firstVerse.surah}:${firstVerse.ayah}',
      'last_verse': '${lastVerse.surah}:${lastVerse.ayah}',
      'surahs': verses.map((v) => v.surah).toSet().toList(),
    };
  }

  /// Total halaman dalam Mushaf
  int getTotalPages() => 604;

  /// Get page number dari surah dan ayat (approximate)
  int getApproximatePageFromSurahAyah(int surah, int ayah) {
    final surahStartPages = {
      1: 1,
      2: 2,
      3: 50,
      4: 77,
      5: 106,
      6: 128,
      7: 151,
      8: 177,
      9: 187,
      10: 208,
      11: 221,
      12: 235,
      13: 249,
      14: 255,
      15: 262,
      16: 267,
      17: 282,
      18: 293,
      19: 305,
      20: 312,
      21: 322,
      22: 332,
      23: 342,
      24: 350,
      25: 359,
      26: 367,
      27: 377,
      28: 385,
      29: 396,
      30: 404,
      31: 411,
      32: 415,
      33: 418,
      34: 428,
      35: 434,
      36: 440,
      37: 446,
      38: 453,
      39: 458,
      40: 467,
      41: 477,
      42: 483,
      43: 489,
      44: 496,
      45: 499,
      46: 502,
      47: 507,
      48: 511,
      49: 515,
      50: 518,
      51: 520,
      52: 523,
      53: 526,
      54: 528,
      55: 531,
      56: 534,
      57: 537,
      58: 542,
      59: 545,
      60: 549,
      61: 551,
      62: 553,
      63: 554,
      64: 556,
      65: 558,
      66: 560,
      67: 562,
      68: 564,
      69: 566,
      70: 568,
      71: 570,
      72: 572,
      73: 574,
      74: 575,
      75: 577,
      76: 578,
      77: 580,
      78: 582,
      79: 583,
      80: 585,
      81: 586,
      82: 587,
      83: 587,
      84: 589,
      85: 590,
      86: 591,
      87: 591,
      88: 592,
      89: 593,
      90: 594,
      91: 595,
      92: 595,
      93: 596,
      94: 596,
      95: 597,
      96: 597,
      97: 598,
      98: 598,
      99: 599,
      100: 599,
      101: 600,
      102: 600,
      103: 601,
      104: 601,
      105: 601,
      106: 602,
      107: 602,
      108: 602,
      109: 603,
      110: 603,
      111: 603,
      112: 604,
      113: 604,
      114: 604,
    };

    return surahStartPages[surah] ?? 1;
  }
}
