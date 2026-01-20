import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  String? currentQari;
  int currentSurah = 1;

  AudioPlayer get player => _player;

  /// =========================
  /// PREPARE (SET URL ONLY)
  /// =========================
  Future<void> prepare({
    required String qari,
    required int surah,
    Duration position = Duration.zero,
  }) async {
    currentQari = qari;
    currentSurah = surah;

    final s = surah.toString().padLeft(3, '0');
    final url = 'https://download.quranicaudio.com/quran/$qari/$s.mp3';

    await _player.stop();
    await _player.setUrl(url);

    if (position > Duration.zero) {
      await _player.seek(position);
    }
  }

  /// ▶️ PLAY
  Future<void> play() => _player.play();

  /// ⏸ PAUSE
  Future<void> pause() => _player.pause();

  /// ⏹ STOP
  Future<void> stop() async {
    await _player.stop();
  }
}
