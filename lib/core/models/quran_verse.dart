import 'package:flutter/material.dart';

class QuranVerse {
  final int surah;
  final int ayah;
  final String text;
  final int? page; // 👈 Tambahkan
  final int? juz; // 👈 Tambahkan
  final int? hizbQuarter; // 👈 Tambahkan (optional)

  QuranVerse({
    required this.surah,
    required this.ayah,
    required this.text,
    this.page,
    this.juz,
    this.hizbQuarter,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    debugPrint(json.toString());

    final parts = (json['verse_key'] as String).split(':');
    return QuranVerse(
      surah: int.parse(parts[0]),
      ayah: int.parse(parts[1]),
      text: json['text_uthmani'],
      page: json['page_number'], // 👈 Tambahkan
      juz: json['juz_number'], // 👈 Tambahkan
      hizbQuarter: json['hizb_number'], // 👈 Tambahkan (optional)
    );
  }
}
