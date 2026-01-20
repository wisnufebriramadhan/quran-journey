import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_tracker/core/models/surah_data.dart';

import '../data/audio_player_service.dart';
import '../data/quran_text_service.dart';
import '../../../core/models/quran_verse.dart';

class QuranReaderPage extends StatefulWidget {
  final int surah;
  final int startingVerse;

  const QuranReaderPage({
    super.key,
    required this.surah,
    this.startingVerse = 1,
  });

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  final QuranTextService _textService = QuranTextService();
  final AudioPlayerService _audio = AudioPlayerService();

  List<QuranVerse> verses = [];

  late int currentSurah;

  /// 🎙 Default qari
  String currentQari = 'abdullaah_3awwaad_al-juhaynee';

  /// 🎧 Available qari
  final List<String> qaris = [
    'abdullaah_3awwaad_al-juhaynee',
    'abdurrahmaan_as-sudays',
    'mishaari_raashid_al-3afaasee',
    'saood_al-shuraym',
  ];

  @override
  void initState() {
    super.initState();
    currentSurah = widget.surah;
    _loadVerses();
    _prepareAudio();
  }

  Future<void> _loadVerses() async {
    final all = await _textService.fetchSurah(currentSurah);
    setState(() => verses = all);
  }

  Future<void> _prepareAudio({Duration? position}) async {
    await _audio.prepare(
      qari: currentQari,
      surah: currentSurah,
      position: position ?? Duration.zero,
    );
  }

  /// =========================
  /// ▶️ PLAY / PAUSE
  /// =========================
  Future<void> _togglePlay() async {
    final state = _audio.player.playerState;

    if (state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering) return;

    if (state.playing) {
      await _audio.pause();
    } else {
      await _audio.play();
    }

    setState(() {});
  }

  /// =========================
  /// 🎙 PICK QARI
  /// =========================
  Future<void> _pickQari() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return ListView(
          children: qaris.map((q) {
            return ListTile(
              title: Text(q.replaceAll('_', ' ')),
              trailing: q == currentQari
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => Navigator.pop(context, q),
            );
          }).toList(),
        );
      },
    );

    if (selected == null || selected == currentQari) return;

    final wasPlaying = _audio.player.playing;
    final pos = _audio.player.position;

    setState(() => currentQari = selected);

    await _prepareAudio(position: pos);

    if (wasPlaying) {
      await _audio.play();
    }
  }

  /// =========================
  /// 📖 PICK SURAH
  /// =========================
  Future<void> _pickSurah() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (_) {
        return ListView(
          children: SurahData.list.map((s) {
            return ListTile(
              leading: Text(s.number.toString()),
              title: Text(s.latin),
              subtitle: Text(
                s.arabic,
                textDirection: TextDirection.rtl,
              ),
              trailing: s.number == currentSurah
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => Navigator.pop(context, s.number),
            );
          }).toList(),
        );
      },
    );

    if (selected == null || selected == currentSurah) return;

    setState(() {
      currentSurah = selected;
      verses.clear();
    });

    await _loadVerses();
    await _prepareAudio();
  }

  @override
  Widget build(BuildContext context) {
    final player = _audio.player;
    final surahInfo = SurahData.byNumber(currentSurah);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: _pickSurah,
          child: Column(
            children: [
              Text(
                surahInfo.latin,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                surahInfo.arabic,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            onPressed: _pickQari,
          ),
        ],
      ),
      body: verses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// 📖 AYAT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Wrap(
                        runSpacing: 28,
                        children: verses.map((v) {
                          return RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'AmiriQuran',
                                fontSize: 28,
                                color: Colors.black,
                                height: 2.0,
                              ),
                              children: [
                                TextSpan(text: v.text),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: AyahNumber(v.ayah),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                /// 🎧 AUDIO CONTROL
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      /// ⏳ PROGRESS
                      StreamBuilder<Duration>(
                        stream: player.positionStream,
                        builder: (_, snap) {
                          final pos = snap.data ?? Duration.zero;
                          final dur = player.duration ?? Duration.zero;

                          return Slider(
                            min: 0,
                            max: dur.inMilliseconds.toDouble(),
                            value: pos.inMilliseconds
                                .clamp(0, dur.inMilliseconds)
                                .toDouble(),
                            onChanged: (v) {
                              player.seek(
                                Duration(milliseconds: v.toInt()),
                              );
                            },
                          );
                        },
                      ),

                      /// ▶️ PLAY / PAUSE
                      IconButton(
                        iconSize: 44,
                        icon: StreamBuilder<PlayerState>(
                          stream: player.playerStateStream,
                          builder: (_, snap) {
                            final playing = snap.data?.playing ?? false;
                            return Icon(
                              playing
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.green,
                            );
                          },
                        ),
                        onPressed: _togglePlay,
                      ),

                      const SizedBox(height: 4),
                      Text(
                        currentQari.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// =========================
/// 🔢 NOMOR AYAT
/// =========================
class AyahNumber extends StatelessWidget {
  final int number;

  const AyahNumber(this.number, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black54),
      ),
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
