import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_tracker/core/models/surah_data.dart';
import '../data/audio_player_service.dart';

class QuranAudioPlayerPage extends StatefulWidget {
  final int surah;

  const QuranAudioPlayerPage({
    super.key,
    required this.surah,
  });

  @override
  State<QuranAudioPlayerPage> createState() => _QuranAudioPlayerPageState();
}

class _QuranAudioPlayerPageState extends State<QuranAudioPlayerPage> {
  final AudioPlayerService _audio = AudioPlayerService();

  late int currentSurah;
  String currentQari = 'abdullaah_3awwaad_al-juhaynee';

  final List<String> qaris = [
    'abdullaah_3awwaad_al-juhaynee',
    'abdurrahmaan_as-sudays',
    'mishaari_raashid_al_3afaasee',
    'bandar_baleela',
    'yasser_ad-dussary',
  ];

  @override
  void initState() {
    super.initState();
    currentSurah = widget.surah;
    _prepareAudio();

    _audio.onSurahChanged = (newSurah) {
      if (!mounted) return;
      setState(() => currentSurah = newSurah);
      _prepareAudio(autoPlay: true);
    };
  }

  @override
  void dispose() {
    _audio.onSurahChanged = null;
    super.dispose();
  }

  Future<void> _prepareAudio({bool autoPlay = false}) async {
    await _audio.prepare(
      qari: currentQari,
      surah: currentSurah,
    );
    if (autoPlay) {
      await _audio.play();
    }
  }

  Future<void> _togglePlay() async {
    final state = _audio.player.playerState;

    if (state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering) return;

    state.playing ? await _audio.pause() : await _audio.play();
    setState(() {});
  }

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

    setState(() => currentSurah = selected);
    await _prepareAudio(autoPlay: true);
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
      body: Column(
        children: [
          const Spacer(),

          /// 🎧 INFO
          Column(
            children: [
              Text(
                'Surah ${surahInfo.latin}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                currentQari.replaceAll('_', ' '),
                style:
                    const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// ⏱ SEEK BAR
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (_, snap) {
              final pos = snap.data ?? Duration.zero;
              final dur = player.duration ?? Duration.zero;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Slider(
                  min: 0,
                  max: dur.inMilliseconds.toDouble(),
                  value: pos.inMilliseconds
                      .clamp(0, dur.inMilliseconds)
                      .toDouble(),
                  onChanged: (v) {
                    _audio.seek(Duration(milliseconds: v.toInt()));
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          /// ⏯ CONTROLS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.skip_previous),
                onPressed: () async {
                  final prev = await _audio.prevSurah();
                  if (prev == null) return;
                  setState(() => currentSurah = prev);
                  await _prepareAudio(autoPlay: true);
                },
              ),
              IconButton(
                iconSize: 64,
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
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.skip_next),
                onPressed: () async {
                  final next = await _audio.nextSurah();
                  if (next == null) return;
                  setState(() => currentSurah = next);
                  await _prepareAudio(autoPlay: true);
                },
              ),
            ],
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
