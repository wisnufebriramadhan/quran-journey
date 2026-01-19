import 'package:flutter/material.dart';
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
  final AudioPlayerService _audioService = AudioPlayerService();

  List<QuranVerse> verses = [];
  bool isPlaying = false;

  static const String _qari = 'abdullaah_3awwaad_al-juhaynee';

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    final all = await _textService.fetchSurah(widget.surah);
    setState(() {
      verses = all;
    });
  }

  // =========================
  // ▶️ PLAY / PAUSE SURAH
  // =========================
  Future<void> _togglePlay() async {
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.playSurah(
        qari: _qari,
        surah: widget.surah,
      );
    }
    setState(() => isPlaying = _audioService.isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Surah ${widget.surah}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: _togglePlay,
          ),
        ],
      ),
      body: verses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    // =========================
                    // 📖 AYAT INLINE
                    // =========================
                    Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 28,
                      children: verses.map((v) {
                        final isHighlighted = v.ayah == widget.startingVerse;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? Colors.grey.shade100
                                : Colors.transparent,
                          ),
                          child: RichText(
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
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// =========================
// 🔢 NOMOR AYAT BULAT
// =========================
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
        border: Border.all(
          color: Colors.black54,
          width: 1,
        ),
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
