import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_colors.dart';

/// Widget untuk menampilkan nomor ayat dengan design melingkar
class MushafAyahNumber extends StatelessWidget {
  final int ayahNumber;
  final bool isNightMode;

  const MushafAyahNumber({
    super.key,
    required this.ayahNumber,
    this.isNightMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgPage = isNightMode ? MushafColors.nightPage : MushafColors.bgPage;
    final ayahCircleColor = isNightMode
        ? MushafColors.goldAccent.withOpacity(0.9)
        : MushafColors.ayahCircle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow layer
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ayahCircleColor.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // Outer circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ayahCircleColor,
                width: 2,
              ),
              color: bgPage,
            ),
          ),
          // Inner circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ayahCircleColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          // Number text
          Text(
            _toArabicNumber(ayahNumber),
            style: TextStyle(
              fontFamily: 'UthmaniHafs',
              fontSize: 15,
              color: ayahCircleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Konversi angka ke format Arab
  String _toArabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((e) => digits[int.parse(e)])
        .join();
  }
}