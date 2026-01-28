import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:quran_tracker/features/murattal/controller/quran_audio_handler.dart';

class AudioPlayerControls extends StatelessWidget {
  final QuranAudioHandler handler;

  const AudioPlayerControls({
    required this.handler,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: handler.playbackState,
      builder: (_, snap) {
        final state = snap.data;
        final playing = state?.playing ?? false;
        final repeat = state?.repeatMode ?? AudioServiceRepeatMode.none;
        final shuffle = state?.shuffleMode == AudioServiceShuffleMode.all;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: shuffle ? const Color(0xFFFFB74D) : Colors.white70,
                    size: 24,
                  ),
                  onPressed: () {
                    handler.setShuffleMode(
                      shuffle
                          ? AudioServiceShuffleMode.none
                          : AudioServiceShuffleMode.all,
                    );
                  },
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: Icon(
                    repeat == AudioServiceRepeatMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                    color: repeat != AudioServiceRepeatMode.none
                        ? const Color(0xFFFFB74D)
                        : Colors.white70,
                    size: 24,
                  ),
                  onPressed: () {
                    if (repeat == AudioServiceRepeatMode.none) {
                      handler.setRepeatMode(AudioServiceRepeatMode.all);
                    } else if (repeat == AudioServiceRepeatMode.all) {
                      handler.setRepeatMode(AudioServiceRepeatMode.one);
                    } else {
                      handler.setRepeatMode(AudioServiceRepeatMode.none);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: handler.skipToPrevious,
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: playing ? handler.pause : handler.play,
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFB74D),
                          Color(0xFFFFB74D),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: handler.skipToNext,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
