import 'package:flutter/material.dart';

class QuranVerse {
  final int surah;
  final int ayah;
  final String text;
  final int? page;
  final int? juz;
  final int? hizbQuarter;

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
      page: json['page_number'],
      juz: json['juz_number'],
      hizbQuarter: json['hizb_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verse_key': '$surah:$ayah',
      'text_uthmani': text,
      'page_number': page,
      'juz_number': juz,
      'hizb_number': hizbQuarter,
    };
  }

  @override
  String toString() {
    return 'QuranVerse(surah: $surah, ayah: $ayah, page: $page, juz: $juz)';
  }
}
