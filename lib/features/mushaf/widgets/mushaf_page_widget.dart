import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/controller/mushaf_page_controller.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_ayah_number.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_bismillah.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_surah_header.dart';
import '../../../core/models/quran_verse.dart';

/// Widget untuk menampilkan satu halaman Mushaf
class MushafPageWidget extends StatelessWidget {
  final int pageNumber;
  final MushafPageController controller;

  const MushafPageWidget({
    super.key,
    required this.pageNumber,
    required this.controller,
  });

  static const bgPage = Color(0xFFFAF6ED);
  static const textColor = Color(0xFF1A1A1A);
  static const ayahCircleColor = Color(0xFF2E7D7D);
  static const goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuranVerse>>(
      future: controller.fetchPageVerses(pageNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        }

        final verses = snapshot.data ?? [];
        if (verses.isEmpty) {
          return const Center(child: Text('Tidak ada data'));
        }

        return _buildContent(verses);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: ayahCircleColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Memuat halaman $pageNumber...',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.red.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<QuranVerse> verses) {
    return Container(
      decoration: BoxDecoration(
        color: bgPage,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _buildDecorativeBorder(),
              const SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.rtl,
                child: _buildVerses(verses),
              ),
              const SizedBox(height: 32),
              _buildDecorativeBorder(),
              const SizedBox(height: 20),
              _buildPageNumber(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeBorder() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            goldAccent.withOpacity(0.4),
            goldAccent,
            goldAccent.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildPageNumber() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: goldAccent,
              width: 2.5,
            ),
            color: bgPage,
            boxShadow: [
              BoxShadow(
                color: goldAccent.withOpacity(0.25),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: goldAccent.withOpacity(0.35),
              width: 1.2,
            ),
          ),
        ),
        Text(
          pageNumber.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVerses(List<QuranVerse> verses) {
    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: 28,
          height: 2.2,
          color: textColor,
          letterSpacing: 0.3,
        ),
        children: verses.expand((v) {
          final spans = <InlineSpan>[];

          if (v.ayah == 1) {
            spans.add(
              WidgetSpan(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    MushafSurahHeader(surahNumber: v.surah),
                    const SizedBox(height: 20),
                    if (v.surah != 1 && v.surah != 9) const MushafBismillah(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          }

          spans.add(TextSpan(text: v.text));
          spans.add(const TextSpan(text: ' '));

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: MushafAyahNumber(ayahNumber: v.ayah),
            ),
          );
          spans.add(const TextSpan(text: ' '));

          return spans;
        }).toList(),
      ),
    );
  }
}
