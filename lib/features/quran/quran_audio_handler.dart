import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_tracker/features/extentions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  /// =====================
  /// STATE
  /// =====================
  String currentQari = 'abdullaah_3awwaad_al-juhaynee';
  int currentSurah = 1;

  bool _isRestoring = false;
  bool _isInitialized = false;

  Stream<Duration> get positionStream => _player.positionStream;

  /// =====================
  /// INIT
  /// =====================
  QuranAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    /// 🔄 Restore last session
    await _restoreLastSession();

    /// 🔊 Player state → notification
    _player.playerStateStream.listen(_broadcastState);

    /// ▶️ Auto next surah
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed &&
          _player.loopMode != LoopMode.one) {
        _nextSurah(autoPlay: true);
      }
    });

    /// ⏱ Save progress
    _player.positionStream.listen((position) {
      playbackState.add(
        playbackState.value.copyWith(updatePosition: position),
      );

      if (position.inSeconds % 3 == 0) {
        _saveResumeState();
      }
    });

    _isInitialized = true;
  }

  /// =====================
  /// LOAD / RESUME
  /// =====================
  Future<void> loadSurah({
    required int surah,
    String? qari,
    bool autoPlay = false,
  }) async {
    if (qari != null) {
      currentQari = qari;
    }

    /// ⛔ Jangan reload kalau masih surah yang sama & audio hidup
    if (_isInitialized &&
        currentSurah == surah &&
        _player.audioSource != null &&
        _player.processingState != ProcessingState.idle) {
      if (autoPlay && !_player.playing) {
        await play();
      }
      return;
    }

    currentSurah = surah;

    final s = surah.toString().padLeft(3, '0');
    final url = 'https://download.quranicaudio.com/quran/$currentQari/$s.mp3';

    try {
      final duration = await _player.setUrl(url);

      /// ✅ PENTING: tandai sudah init
      _isInitialized = true;

      /// ✅ AMBIL NAMA SURAH ASLI
      final surahName =
          (surah >= 1 && surah <= 114) ? surahNames[surah - 1] : 'Unknown';

      mediaItem.add(
        MediaItem(
          id: surah.toString(),
          album: 'Al-Qur’an',
          title: surahName, // 🔥 FIX UTAMA
          artist: currentQari.replaceAll('_', ' '),
          duration: duration,
        ),
      );

      if (autoPlay) {
        await play();
      }
    } catch (e) {
      debugPrint('❌ Audio load error: $e');
    }
  }

  /// =====================
  /// RESUME STORAGE
  /// =====================
  Future<void> _saveResumeState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah', currentSurah);
    await prefs.setInt(
      'last_position',
      _player.position.inMilliseconds,
    );
    await prefs.setString('last_qari', currentQari);
  }

  Future<void> _restoreLastSession() async {
    final prefs = await SharedPreferences.getInstance();

    final surah = prefs.getInt('last_surah');
    final posMs = prefs.getInt('last_position');
    final qari = prefs.getString('last_qari');

    if (surah == null) return;

    _isRestoring = true;

    await loadSurah(
      surah: surah,
      qari: qari,
      autoPlay: false,
    );

    if (posMs != null) {
      await _player.seek(Duration(milliseconds: posMs));
    }

    _isRestoring = false;
  }

  /// =====================
  /// CONTROLS
  /// =====================
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _nextSurah(autoPlay: true);

  @override
  Future<void> skipToPrevious() => _prevSurah(autoPlay: true);

  /// =====================
  /// REPEAT / SHUFFLE
  /// =====================
  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));

    switch (repeatMode) {
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
      default:
        await _player.setLoopMode(LoopMode.off);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
    playbackState.add(
      playbackState.value.copyWith(shuffleMode: shuffleMode),
    );
  }

  /// =====================
  /// SURAH NAVIGATION
  /// =====================
  Future<void> _nextSurah({bool autoPlay = false}) async {
    int next = currentSurah + 1;
    if (next > 114) next = 1;
    await loadSurah(surah: next, autoPlay: autoPlay);
  }

  Future<void> _prevSurah({bool autoPlay = false}) async {
    int prev = currentSurah - 1;
    if (prev < 1) prev = 114;
    await loadSurah(surah: prev, autoPlay: autoPlay);
  }

  /// =====================
  /// NOTIFICATION STATE
  /// =====================
  void _broadcastState(PlayerState state) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          state.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.setRepeatMode,
          MediaAction.setShuffleMode,
        },
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[state.processingState]!,
        playing: state.playing,
        updatePosition: _player.position,
        repeatMode: playbackState.value.repeatMode,
        shuffleMode: playbackState.value.shuffleMode,
      ),
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    await _saveResumeState();
    await super.onTaskRemoved();
  }
}
