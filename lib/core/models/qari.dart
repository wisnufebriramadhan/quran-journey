enum QariUrlType {
  complete,
  direct,
}

class Qari {
  final String id; // folder name di Quranicaudio
  final String name; // nama tampil
  final QariUrlType type; // struktur URL

  const Qari({
    required this.id,
    required this.name,
    required this.type,
  });

  /// =========================
  /// BUILD AUDIO URL
  /// =========================
  String buildUrl(int surah) {
    final s = surah.toString().padLeft(3, '0');

    switch (type) {
      case QariUrlType.complete:
        return 'https://download.quranicaudio.com/quran/$id/complete/$s.mp3';
      case QariUrlType.direct:
        return 'https://download.quranicaudio.com/quran/$id/$s.mp3';
    }
  }
}
