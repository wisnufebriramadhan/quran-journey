import 'package:flutter/material.dart';
import 'package:quran_tracker/features/mushaf/widgets/mushaf_colors.dart';

/// Widget untuk menampilkan Bismillah
class MushafBismillah extends StatelessWidget {
  final bool isNightMode;

  const MushafBismillah({
    super.key,
    this.isNightMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isNightMode ? MushafColors.nightText : const Color(0xFF1A1A1A);
    final cardColor = isNightMode
        ? MushafColors.goldAccent.withOpacity(0.1)
        : MushafColors.goldAccent.withOpacity(0.06);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MushafColors.goldAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'UthmaniHafs',
          fontSize: 26,
          height: 2.0,
          color: textColor,
        ),
      ),
    );
  }
}