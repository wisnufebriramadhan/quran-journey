import 'package:flutter/material.dart';

/// Widget untuk menampilkan Bismillah
class MushafBismillah extends StatelessWidget {
  const MushafBismillah({super.key});

  static const textColor = Color(0xFF1A1A1A);
  static const goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: goldAccent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goldAccent.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: const Text(
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