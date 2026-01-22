import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:quran_tracker/features/extentions.dart';
import 'package:quran_tracker/features/quran/audio_locator.dart';
import 'package:quran_tracker/features/quran/quran_audio_handler.dart';

class QuranAudioPlayerPage extends StatefulWidget {
  final int initialSurah;

  const QuranAudioPlayerPage({
    super.key,
    required this.initialSurah,
  });

  @override
  State<QuranAudioPlayerPage> createState() => _QuranAudioPlayerPageState();
}

const bgBrown = Color(0xFF3E2F23);
const cardBrown = Color(0xFF4A3728);
const accentGold = Color(0xFFC9A24D);

class _QuranAudioPlayerPageState extends State<QuranAudioPlayerPage> {
  late final QuranAudioHandler handler;

  @override
  void initState() {
    super.initState();
    handler = audioHandler as QuranAudioHandler;

    /// 🔒 SATU-SATUNYA pintu load (ANTI RESET)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialSurah();
    });
  }

  Future<void> _loadInitialSurah() async {
    final currentItem = handler.mediaItem.value;
    final processingState = handler.playbackState.value.processingState;

    /// ✅ Jika audio sudah hidup → JANGAN RESET
    if (currentItem != null && processingState != AudioProcessingState.idle) {
      return;
    }

    /// ✅ Load pertama kali saja
    await handler.loadSurah(
      surah: widget.initialSurah,
      autoPlay: true,
    );
  }

  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  // ==========================
  // SURAH PICKER
  // ==========================
  Future<void> _showSurahPicker() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pilih Surah'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: 114,
            itemBuilder: (_, i) {
              final no = i + 1;
              return ListTile(
                leading: CircleAvatar(child: Text('$no')),
                title: Text(surahNames[i]),
                selected: handler.currentSurah == no,
                onTap: () => Navigator.pop(context, no),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      await handler.loadSurah(
        surah: selected,
        autoPlay: true,
      );
    }
  }

  // ==========================
  // QARI PICKER (BARU)
  // ==========================
  Future<void> _showQariPicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pilih Qari'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: qariList.length,
            itemBuilder: (_, i) {
              final qari = qariList[i];
              return ListTile(
                title: Text(qari['name']!),
                selected: handler.currentQari == qari['id'],
                onTap: () => Navigator.pop(context, qari['id']),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      await handler.loadSurah(
        surah: handler.currentSurah,
        qari: selected,
        autoPlay: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(' '),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// 🎧 PLAYER CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 50,
              ),
              child: Column(
                children: [
                  const Spacer(),

                  /// PLAYER CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D4037).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// ICON
                        Container(
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                            color: bgBrown,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 88,
                            color: accentGold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// SURAH + QARI
                        StreamBuilder<MediaItem?>(
                          stream: handler.mediaItem,
                          builder: (_, snap) {
                            final item = snap.data;
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: _showSurahPicker,
                                  child: Text(
                                    item?.title ?? 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: _showQariPicker,
                                  child: Text(
                                    item?.artist ?? handler.currentQari,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        /// PROGRESS
                        StreamBuilder<Duration>(
                          stream: handler.positionStream,
                          builder: (_, posSnap) {
                            final position = posSnap.data ?? Duration.zero;
                            final duration =
                                handler.mediaItem.value?.duration ??
                                    Duration.zero;

                            return Column(
                              children: [
                                Slider(
                                  value: position.inSeconds
                                      .clamp(0, duration.inSeconds)
                                      .toDouble(),
                                  max: duration.inSeconds
                                      .toDouble()
                                      .clamp(1, double.infinity),
                                  activeColor: accentGold,
                                  inactiveColor: Colors.white24,
                                  onChanged: (v) => handler
                                      .seek(Duration(seconds: v.toInt())),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_format(position),
                                        style: const TextStyle(
                                            color: Colors.white60)),
                                    Text(_format(duration),
                                        style: const TextStyle(
                                            color: Colors.white60)),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        /// 🔁 SHUFFLE & REPEAT (TETAP ADA, RAPI)
                        StreamBuilder<PlaybackState>(
                          stream: handler.playbackState,
                          builder: (_, snap) {
                            final state = snap.data;
                            final playing = state?.playing ?? false;
                            final repeat = state?.repeatMode ??
                                AudioServiceRepeatMode.none;
                            final shuffle = state?.shuffleMode ==
                                AudioServiceShuffleMode.all;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.shuffle,
                                        color: shuffle
                                            ? accentGold
                                            : Colors.white38,
                                      ),
                                      onPressed: () {
                                        handler.setShuffleMode(
                                          shuffle
                                              ? AudioServiceShuffleMode.none
                                              : AudioServiceShuffleMode.all,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        repeat == AudioServiceRepeatMode.one
                                            ? Icons.repeat_one
                                            : Icons.repeat,
                                        color: repeat !=
                                                AudioServiceRepeatMode.none
                                            ? accentGold
                                            : Colors.white38,
                                      ),
                                      onPressed: () {
                                        if (repeat ==
                                            AudioServiceRepeatMode.none) {
                                          handler.setRepeatMode(
                                              AudioServiceRepeatMode.all);
                                        } else if (repeat ==
                                            AudioServiceRepeatMode.all) {
                                          handler.setRepeatMode(
                                              AudioServiceRepeatMode.one);
                                        } else {
                                          handler.setRepeatMode(
                                              AudioServiceRepeatMode.none);
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                /// MAIN CONTROLS
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.skip_previous,
                                        color: Colors.white,
                                      ),
                                      onPressed: handler.skipToPrevious,
                                    ),
                                    GestureDetector(
                                      onTap: playing
                                          ? handler.pause
                                          : handler.play,
                                      child: CircleAvatar(
                                        radius: 34,
                                        backgroundColor: accentGold,
                                        child: Icon(
                                          playing
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 38,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.skip_next,
                                        color: Colors.white,
                                      ),
                                      onPressed: handler.skipToNext,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
