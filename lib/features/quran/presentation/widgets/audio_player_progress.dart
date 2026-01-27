import 'package:flutter/material.dart';
import 'package:quran_tracker/features/quran/quran_audio_handler.dart';

class AudioPlayerProgress extends StatelessWidget {
  final QuranAudioHandler handler;

  const AudioPlayerProgress({
    required this.handler,
    super.key,
  });

  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: handler.positionStream,
      builder: (_, posSnap) {
        final position = posSnap.data ?? Duration.zero;
        final duration = handler.mediaItem.value?.duration ?? Duration.zero;

        return Column(
          children: [
            SliderTheme(
              data: const SliderThemeData(
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: 16,
                ),
              ),
              child: Slider(
                value:
                    position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
                max: duration.inSeconds.toDouble().clamp(1, double.infinity),
                activeColor: const Color(0xFFFFB74D),
                inactiveColor: Colors.white.withOpacity(0.2),
                onChanged: (v) => handler.seek(Duration(seconds: v.toInt())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _format(position),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _format(duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
