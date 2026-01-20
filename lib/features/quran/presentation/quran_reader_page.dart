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
    _prepareAudioIfNeeded();
  }

  /// =========================
  /// LOAD AYAT
  /// =========================
  Future<void> _loadVerses() async {
    final all = await _textService.fetchSurah(currentSurah);
    if (!mounted) return;
    setState(() => verses = all);
  }

  /// =========================
  /// PREPARE AUDIO
  /// =========================
  Future<void> _prepareAudioIfNeeded() async {
    await _audio.prepare(
      qari: currentQari,
      surah: currentSurah,
    );
  }

  /// =========================
  /// ▶️ PLAY / PAUSE
  /// =========================
  Future<void> _togglePlay() async {
    final state = _audio.player.playerState;

    if (state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering) return;

    state.playing ? await _audio.pause() : await _audio.play();
    setState(() {});
  }

  /// =========================
  /// 🎙 PICK QARI
  /// =========================
  Future<void> _pickQari() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        children: qaris.map((q) {
          return ListTile(
            title: Text(q.replaceAll('_', ' ')),
            trailing: q == currentQari ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, q),
          );
        }).toList(),
      ),
    );

    if (selected == null || selected == currentQari) return;

    final wasPlaying = _audio.isPlaying;
    final pos = _audio.player.position;

    setState(() => currentQari = selected);

    await _audio.prepare(qari: currentQari, surah: currentSurah);
    if (pos > Duration.zero) await _audio.seek(pos);
    if (wasPlaying) await _audio.play();
  }

  /// =========================
  /// 📖 PICK SURAH
  /// =========================
  Future<void> _pickSurah() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => ListView(
        children: SurahData.list.map((s) {
          return ListTile(
            leading: Text(s.number.toString()),
            title: Text(s.latin),
            subtitle: Text(s.arabic, textDirection: TextDirection.rtl),
            trailing: s.number == currentSurah ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, s.number),
          );
        }).toList(),
      ),
    );

    if (selected == null || selected == currentSurah) return;

    setState(() {
      currentSurah = selected;
      verses.clear();
    });

    await _loadVerses();
    await _audio.prepare(qari: currentQari, surah: currentSurah);
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
              Text(surahInfo.latin,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(surahInfo.arabic, style: const TextStyle(fontSize: 12)),
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
                /// ================= AYAT =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 12, bottom: 12),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'AmiriQuran',
                            fontSize: 28,
                            color: Colors.black,
                            height: 2.4,
                          ),
                          children: verses.expand((v) {
                            return [
                              TextSpan(text: '${v.text} '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: AyahNumber(v.ayah),
                              ),
                              const TextSpan(text: ' '),
                            ];
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                /// ================= AUDIO =================
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
                              _audio.seek(Duration(milliseconds: v.toInt()));
                            },
                          );
                        },
                      ),
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
                      Text(
                        currentQari.replaceAll('_', ' '),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
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
/// 🔢 NOMOR AYAT (ARABIC)
/// =========================
class AyahNumber extends StatelessWidget {
  final int number;

  const AyahNumber(this.number, {super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -1.8),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 8),
        transformAlignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black54),
        ),
        child: Text(
          toArabicNumber(number),
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// =========================
/// 🔤 ANGKA ARAB
/// =========================
String toArabicNumber(int number) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number
      .toString()
      .split('')
      .map((e) => arabicDigits[int.parse(e)])
      .join();
}
