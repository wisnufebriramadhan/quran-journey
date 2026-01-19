import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/quran_verse.dart';

class QuranTextService {
  Future<List<QuranVerse>> fetchSurah(int surah) async {
    final url = Uri.parse(
      'https://api.quran.com/api/v4/quran/verses/uthmani?chapter_number=$surah',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil ayat');
    }

    final data = jsonDecode(response.body);
    final List verses = data['verses'];

    return verses
        .map((e) => QuranVerse.fromJson(e))
        .toList();
  }
}
