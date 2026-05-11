import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/controller/mushaf_page_controller.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_ayah_number.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_bismillah.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final isNight = controller.isNightMode;
    final pageColor = isNight ? MushafColors.nightPage : MushafColors.bgPage;
    final textColor = isNight ? MushafColors.nightText : const Color(0xFF1A1A1A);
    final baseFontSize = controller.isComfortReading ? 31.0 : 27.5;
    final lineHeight = controller.isComfortReading ? 2.3 : 2.1;

    return FutureBuilder<List<QuranVerse>>(
      future: controller.fetchPageVerses(pageNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(textColor);
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        }

        final verses = snapshot.data ?? [];
        if (verses.isEmpty) {
          return const Center(child: Text('Tidak ada data'));
        }

        return _buildContent(
          verses,
          pageColor: pageColor,
          textColor: textColor,
          baseFontSize: baseFontSize,
          lineHeight: lineHeight,
        );
      },
    );
  }

  Widget _buildLoadingState(Color textColor) {
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
              color: MushafColors.ayahCircle,
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

  Widget _buildContent(
    List<QuranVerse> verses, {
    required Color pageColor,
    required Color textColor,
    required double baseFontSize,
    required double lineHeight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: pageColor,
        border: Border.all(
          color: MushafColors.goldAccent.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            children: [
              _buildTopMetaCard(textColor),
              const SizedBox(height: 20),
              _buildDecorativeBorder(),
              const SizedBox(height: 18),
              Directionality(
                textDirection: TextDirection.rtl,
                child: _buildVerses(
                  verses,
                  textColor: textColor,
                  baseFontSize: baseFontSize,
                  lineHeight: lineHeight,
                ),
              ),
              const SizedBox(height: 32),
              _buildDecorativeBorder(),
              const SizedBox(height: 20),
              _buildPageNumber(textColor),
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
            MushafColors.goldAccent.withOpacity(0.4),
            MushafColors.goldAccent,
            MushafColors.goldAccent.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildTopMetaCard(Color textColor) {
    final primaryTextColor = controller.isNightMode
        ? MushafColors.nightText
        : MushafColors.appBarBrown;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: MushafColors.goldAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MushafColors.goldAccent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hal. $pageNumber',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          Text(
            controller.isComfortReading ? 'Baca Nyaman: ON' : 'Baca Nyaman: OFF',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumber(Color textColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: MushafColors.goldAccent,
              width: 2.5,
            ),
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: MushafColors.goldAccent.withOpacity(0.25),
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
              color: MushafColors.goldAccent.withOpacity(0.35),
              width: 1.2,
            ),
          ),
        ),
        Text(
          pageNumber.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVerses(
    List<QuranVerse> verses, {
    required Color textColor,
    required double baseFontSize,
    required double lineHeight,
  }) {
    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: baseFontSize,
          height: lineHeight,
          color: textColor,
          letterSpacing: 0.2,
        ),
        children: verses.expand((v) {
          final spans = <InlineSpan>[];

          if (v.ayah == 1) {
            spans.add(
              WidgetSpan(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    MushafSurahHeader(
                      surahNumber: v.surah,
                      isNightMode: controller.isNightMode,
                    ),
                    const SizedBox(height: 20),
                    if (v.surah != 1 && v.surah != 9)
                      MushafBismillah(isNightMode: controller.isNightMode),
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
              child: MushafAyahNumber(
                ayahNumber: v.ayah,
                isNightMode: controller.isNightMode,
              ),
            ),
          );
          spans.add(const TextSpan(text: ' '));

          return spans;
        }).toList(),
      ),
    );
  }
}
