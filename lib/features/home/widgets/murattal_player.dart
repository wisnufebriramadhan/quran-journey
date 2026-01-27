import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:quran_tracker/features/quran/audio_locator.dart';
import 'package:quran_tracker/features/quran/quran_audio_handler.dart';
import 'package:quran_tracker/features/quran/presentation/quran_audio_player_page.dart';

class MurattalPlayerWidget extends StatefulWidget {
  const MurattalPlayerWidget({super.key});

  @override
  State<MurattalPlayerWidget> createState() => _MurattalPlayerWidgetState();
}

class _MurattalPlayerWidgetState extends State<MurattalPlayerWidget> {
  late final QuranAudioHandler handler;

  @override
  void initState() {
    super.initState();
    handler = audioHandler as QuranAudioHandler;
  }

  void _openFullPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranAudioPlayerPage(
          initialSurah: handler.currentSurah,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFullPlayer,
      child: StreamBuilder<MediaItem?>(
        stream: handler.mediaItem,
        builder: (context, mediaSnapshot) {
          return StreamBuilder<PlaybackState>(
            stream: handler.playbackState,
            builder: (context, playbackSnapshot) {
              final mediaItem = mediaSnapshot.data;
              final playbackState = playbackSnapshot.data;
              final isPlaying = playbackState?.playing ?? false;
              final processingState =
                  playbackState?.processingState ?? AudioProcessingState.idle;

              return StreamBuilder<Duration>(
                stream: handler.positionStream,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  final duration = mediaItem?.duration ?? Duration.zero;
                  final progress = duration.inSeconds > 0
                      ? position.inSeconds / duration.inSeconds
                      : 0.0;

                  final surahName = mediaItem?.title ?? 'Al-Fatihah';

                  return _buildPlayerCard(
                    surahName,
                    progress,
                    isPlaying,
                    processingState,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlayerCard(
    String surahName,
    double progress,
    bool isPlaying,
    AudioProcessingState processingState,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4037).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPlayButton(isPlaying, processingState),
          const SizedBox(width: 14),
          Expanded(
            child: _buildPlayerInfo(surahName, progress),
          ),
          const SizedBox(width: 14),
          _buildSkipButtons(),
        ],
      ),
    );
  }

  Widget _buildPlayButton(
      bool isPlaying, AudioProcessingState processingState) {
    return GestureDetector(
      onTap: () {
        if (processingState == AudioProcessingState.idle) {
          handler.loadSurah(surah: 1, autoPlay: true);
        } else if (isPlaying) {
          handler.pause();
        } else {
          handler.play();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          processingState == AudioProcessingState.loading ||
                  processingState == AudioProcessingState.buffering
              ? Icons.hourglass_empty_rounded
              : isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
          color: const Color(0xFF5D4037),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String surahName, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                surahName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.open_in_full_rounded,
              color: Colors.white.withOpacity(0.6),
              size: 14,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.amber.shade300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButtons() {
    return Row(
      children: [
        _MiniPlayerButton(
          icon: Icons.skip_previous_rounded,
          onTap: () => handler.skipToPrevious(),
        ),
        const SizedBox(width: 8),
        _MiniPlayerButton(
          icon: Icons.skip_next_rounded,
          onTap: () => handler.skipToNext(),
        ),
      ],
    );
  }
}

class _MiniPlayerButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniPlayerButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_MiniPlayerButton> createState() => _MiniPlayerButtonState();
}

class _MiniPlayerButtonState extends State<_MiniPlayerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
