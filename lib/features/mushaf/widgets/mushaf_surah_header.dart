import 'package:flutter/material.dart';
import '../../../../core/models/surah_data.dart';
import 'mushaf_colors.dart';
import 'surah_header_painter.dart';

/// Widget untuk menampilkan header Surah
class MushafSurahHeader extends StatelessWidget {
  final int surahNumber;
  final bool isNightMode;

  const MushafSurahHeader({
    super.key,
    required this.surahNumber,
    this.isNightMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final surah = SurahData.byNumber(surahNumber);
    final textColor = isNightMode ? MushafColors.nightText : const Color(0xFF1A1A1A);
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(double.infinity, 80),
              painter: EnhancedSurahHeaderPainter(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'سُورَةُ ${surah.arabic}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'UthmaniHafs',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      shadows: [
                        Shadow(
                          color: MushafColors.goldAccent.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.latin,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}