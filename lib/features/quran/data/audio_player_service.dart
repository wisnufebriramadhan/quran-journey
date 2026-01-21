import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;
  
  AudioPlayerService._internal() {
    _initAudioSession();
    _setupAutoNext();
  }

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<ProcessingState>? _autoNextSub;

  String? currentQari;
  int? currentSurah;

  /// 🔥 Callback untuk notify UI bahwa surah berganti
  Function(int newSurah)? onSurahChanged;

  /// =========================
  /// 🔥 INIT AUDIO SESSION
  /// =========================
  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  /// =========================
  /// 🔥 SETUP AUTO NEXT
  /// =========================
  void _setupAutoNext() {
    _autoNextSub = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleAutoNext();
      }
    });
  }

  /// =========================
  /// 🔥 HANDLE AUTO NEXT
  /// =========================
  Future<void> _handleAutoNext() async {
    if (currentQari == null || currentSurah == null) return;

    int next = currentSurah! + 1;
    if (next > 114) next = 1;

    await prepare(qari: currentQari!, surah: next);
    await play();

    onSurahChanged?.call(next);
  }

  /// =========================
  /// GETTERS
  /// =========================
  AudioPlayer get player => _player;

  bool get isPlaying => _player.playing;

  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;
      
  Stream<Duration> get positionStream => _player.positionStream;
      
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// =========================
  /// PREPARE AUDIO
  /// =========================
  Future<void> prepare({
    required String qari,
    required int surah,
    String? surahName,
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
  /// DISPOSE
  /// =========================
  Future<void> dispose() async {
    await _autoNextSub?.cancel();
    await _player.dispose();
  }
}