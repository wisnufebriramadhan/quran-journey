import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance =
      AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  String? currentQari;
  int? currentSurah;

  AudioPlayer get player => _player;

  bool get isPlaying => _player.playing;

  /// =========================
  /// PREPARE (SET URL ONLY)
  /// - Tidak reset kalau qari & surah sama
  /// =========================
  Future<void> prepare({
    required String qari,
    required int surah,
  }) async {
    // 🛑 Jangan reload audio kalau masih sama
    if (currentQari == qari && currentSurah == surah) {
      return;
    }

    currentQari = qari;
    currentSurah = surah;

    final s = surah.toString().padLeft(3, '0');
    final url = 'https://download.quranicaudio.com/quran/$qari/$s.mp3';

    await _player.setUrl(url);
  }

  /// ▶️ PLAY
  Future<void> play() async {
    if (!_player.playing) {
      await _player.play();
    }
  }

  /// ⏸ PAUSE
  Future<void> pause() async {
    if (_player.playing) {
      await _player.pause();
    }
  }

  /// ⏹ STOP (jarang dipakai)
  Future<void> stop() async {
    await _player.stop();
  }

  /// ⏩ SEEK (untuk progress bar nanti)
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// 🔁 NEXT SURAH
  Future<void> nextSurah() async {
    if (currentQari == null || currentSurah == null) return;

    int next = currentSurah! + 1;
    if (next > 114) next = 1;

    await prepare(qari: currentQari!, surah: next);
    await play();
  }

  /// ⏮ PREVIOUS SURAH
  Future<void> prevSurah() async {
    if (currentQari == null || currentSurah == null) return;

    int prev = currentSurah! - 1;
    if (prev < 1) prev = 114;

    await prepare(qari: currentQari!, surah: prev);
    await play();
  }
}
