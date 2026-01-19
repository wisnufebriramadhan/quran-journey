import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  static const _keyQari = 'last_qari';
  static const _keySurah = 'last_surah';
  static const _keyPosition = 'last_position';

  String? currentQari;
  int currentSurah = 1;

  AudioPlayer get player => _player;
  bool get isPlaying => _player.playing;

  // =========================
  // ▶️ INIT (AUTO RESUME)
  // =========================
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentQari = prefs.getString(_keyQari);
    currentSurah = prefs.getInt(_keySurah) ?? 1;
    final pos = prefs.getInt(_keyPosition) ?? 0;

    if (currentQari != null) {
      await playSurah(
        qari: currentQari!,
        surah: currentSurah,
        startPosition: Duration(milliseconds: pos),
      );
    }
  }

  // =========================
  // ▶️ PLAY SURAH
  // =========================
  Future<void> playSurah({
    required String qari,
    required int surah,
    Duration startPosition = Duration.zero,
  }) async {
    currentQari = qari;
    currentSurah = surah;

    final s = surah.toString().padLeft(3, '0');
    final url = 'https://download.quranicaudio.com/quran/$qari/$s.mp3';

    await _player.stop();
    await _player.setUrl(url);

    if (startPosition > Duration.zero) {
      await _player.seek(startPosition);
    }

    await _player.play();
    _listenProgress();
  }

  // =========================
  // ⏸ PAUSE
  // =========================
  Future<void> pause() async {
    await _saveState();
    await _player.pause();
  }

  // =========================
  // ⏭ NEXT SURAH
  // =========================
  Future<void> nextSurah() async {
    currentSurah++;
    if (currentSurah > 114) currentSurah = 1;
    await playSurah(
      qari: currentQari!,
      surah: currentSurah,
    );
  }

  // =========================
  // 💾 SAVE STATE
  // =========================
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyQari, currentQari ?? '');
    await prefs.setInt(_keySurah, currentSurah);
    await prefs.setInt(
      _keyPosition,
      _player.position.inMilliseconds,
    );
  }

  // =========================
  // 🔁 AUTO NEXT + SAVE
  // =========================
  void _listenProgress() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        nextSurah();
      }
    });
  }
}
