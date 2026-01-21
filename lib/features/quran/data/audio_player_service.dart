import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  String? currentQari;
  int? currentSurah;

  /// =========================
  /// GETTERS
  /// =========================
  AudioPlayer get player => _player;

  bool get isPlaying => _player.playing;

  /// 🔔 expose processing state (untuk auto-next)
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  /// =========================
  /// PREPARE AUDIO
  /// - tidak reload jika qari & surah sama
  /// =========================
  Future<void> prepare({
    required String qari,
    required int surah,
  }) async {
    if (currentQari == qari && currentSurah == surah) return;

    currentQari = qari;
    currentSurah = surah;

    final s = surah.toString().padLeft(3, '0');
    final url = 'https://download.quranicaudio.com/quran/$qari/$s.mp3';

    await _player.setUrl(url);
  }

  /// =========================
  /// PLAY / PAUSE / STOP
  /// =========================
  Future<void> play() async {
    if (!_player.playing) {
      await _player.play();
    }
  }

  Future<void> pause() async {
    if (_player.playing) {
      await _player.pause();
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  /// =========================
  /// SEEK
  /// =========================
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// =========================
  /// NEXT SURAH
  /// =========================
  Future<int?> nextSurah() async {
    if (currentQari == null || currentSurah == null) return null;

    int next = currentSurah! + 1;
    if (next > 114) next = 1;

    await prepare(qari: currentQari!, surah: next);
    await play();

    return next;
  }

  /// =========================
  /// PREVIOUS SURAH
  /// =========================
  Future<int?> prevSurah() async {
    if (currentQari == null || currentSurah == null) return null;

    int prev = currentSurah! - 1;
    if (prev < 1) prev = 114;

    await prepare(qari: currentQari!, surah: prev);
    await play();

    return prev;
  }

  /// =========================
  /// DISPOSE (kalau perlu)
  /// =========================
  Future<void> dispose() async {
    await _player.dispose();
  }
}
