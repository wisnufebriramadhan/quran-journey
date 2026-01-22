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

class _QuranAudioPlayerPageState extends State<QuranAudioPlayerPage>
    with SingleTickerProviderStateMixin {
  late final QuranAudioHandler handler;
  late AnimationController _rotationController;
  bool _showSpeedControl = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    handler = audioHandler as QuranAudioHandler;
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialSurah();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSurah() async {
    final currentItem = handler.mediaItem.value;
    final processingState = handler.playbackState.value.processingState;

    if (currentItem != null && processingState != AudioProcessingState.idle) {
      return;
    }

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

  Future<void> _showSurahPicker() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Surah',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: 114,
                  itemBuilder: (_, i) {
                    final no = i + 1;
                    final isSelected = handler.currentSurah == no;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentGold.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? accentGold : cardBrown,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$no',
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          surahNames[i],
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.play_circle_filled,
                                color: accentGold)
                            : null,
                        onTap: () => Navigator.pop(context, no),
                      ),
                    );
                  },
                ),
              ),
            ],
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

  Future<void> _showQariPicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Qari',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: qariList.length,
                  itemBuilder: (_, i) {
                    final qari = qariList[i];
                    final isSelected = handler.currentQari == qari['id'];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentGold.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color: isSelected ? accentGold : cardBrown,
                        ),
                        title: Text(
                          qari['name']!,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: accentGold)
                            : null,
                        onTap: () => Navigator.pop(context, qari['id']),
                      ),
                    );
                  },
                ),
              ),
            ],
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

  void _showSpeedMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kecepatan Putar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
              return ListTile(
                leading: Icon(
                  _playbackSpeed == speed
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _playbackSpeed == speed ? accentGold : null,
                ),
                title: Text('${speed}x'),
                onTap: () {
                  setState(() => _playbackSpeed = speed);
                  handler.changeSpeed(speed);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5D4037)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.speed, color: Color(0xFF5D4037)),
            onPressed: _showSpeedMenu,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5F1E8),
              const Color(0xFFE8DCC8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// ANIMATED ICON
                StreamBuilder<PlaybackState>(
                  stream: handler.playbackState,
                  builder: (_, snap) {
                    final playing = snap.data?.playing ?? false;

                    if (playing) {
                      _rotationController.repeat();
                    } else {
                      _rotationController.stop();
                    }

                    return RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accentGold.withOpacity(0.3),
                              const Color(0xFF5D4037),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentGold.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                /// SURAH & QARI INFO
                StreamBuilder<MediaItem?>(
                  stream: handler.mediaItem,
                  builder: (_, snap) {
                    final item = snap.data;
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: _showSurahPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item?.title ?? 'Loading...',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: accentGold,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showQariPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: cardBrown.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Color(0xFF5D4037),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item?.artist ?? handler.currentQari,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: Color(0xFF5D4037),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(),

                /// PROGRESS BAR
                StreamBuilder<Duration>(
                  stream: handler.positionStream,
                  builder: (_, posSnap) {
                    final position = posSnap.data ?? Duration.zero;
                    final duration =
                        handler.mediaItem.value?.duration ?? Duration.zero;

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                          ),
                          child: Slider(
                            value: position.inSeconds
                                .clamp(0, duration.inSeconds)
                                .toDouble(),
                            max: duration.inSeconds
                                .toDouble()
                                .clamp(1, double.infinity),
                            activeColor: accentGold,
                            inactiveColor: cardBrown.withOpacity(0.3),
                            onChanged: (v) =>
                                handler.seek(Duration(seconds: v.toInt())),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _format(position),
                                style: TextStyle(
                                  color: cardBrown,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _format(duration),
                                style: TextStyle(
                                  color: cardBrown,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// CONTROLS
                StreamBuilder<PlaybackState>(
                  stream: handler.playbackState,
                  builder: (_, snap) {
                    final state = snap.data;
                    final playing = state?.playing ?? false;
                    final repeat =
                        state?.repeatMode ?? AudioServiceRepeatMode.none;
                    final shuffle =
                        state?.shuffleMode == AudioServiceShuffleMode.all;

                    return Column(
                      children: [
                        /// SHUFFLE & REPEAT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.shuffle,
                                color: shuffle ? accentGold : cardBrown,
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
                                    ? accentGold
                                    : cardBrown,
                                size: 24,
                              ),
                              onPressed: () {
                                if (repeat == AudioServiceRepeatMode.none) {
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

                        const SizedBox(height: 16),

                        /// MAIN CONTROLS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
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
                                  color: Color(0xFF5D4037),
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
                                  gradient: LinearGradient(
                                    colors: [
                                      accentGold,
                                      accentGold.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentGold.withOpacity(0.4),
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
                                color: Colors.white,
                                shape: BoxShape.circle,
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
                                  color: Color(0xFF5D4037),
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
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
