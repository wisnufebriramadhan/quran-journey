import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_tracker/core/models/surah_data.dart';
import 'package:quran_tracker/features/quran/data/audio_player_service.dart';
import 'package:quran_tracker/features/quran/presentation/quran_reader_page.dart';

class MiniPlayer extends StatelessWidget {
  MiniPlayer({super.key});

  final AudioPlayerService audio = AudioPlayerService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audio.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isPlaying = state?.playing ?? false;

        if (state == null || audio.currentSurah == null) {
          return const SizedBox.shrink();
        }

        final currentSurah = audio.currentSurah!;
        final surahInfo = SurahData.byNumber(currentSurah);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranAudioPlayerPage(
                  surah: currentSurah,
                ),
              ),
            );
          },
          child: Container(
            height: 90,
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.brown, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surahInfo.latin,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            surahInfo.arabic,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              audio.currentQari?.replaceAll('_', ' ') ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder<Duration>(
                        stream: audio.positionStream,
                        builder: (_, snap) {
                          final pos = snap.data ?? Duration.zero;
                          final dur = audio.player.duration ?? Duration.zero;
                          return LinearProgressIndicator(
                            value: dur.inMilliseconds == 0
                                ? 0
                                : (pos.inMilliseconds / dur.inMilliseconds)
                                    .clamp(0, 1),
                            minHeight: 2,
                            backgroundColor: Colors.brown.withOpacity(0.2),
                            color: Colors.brown,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 32,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.brown,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      audio.pause();
                    } else {
                      audio.play();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
