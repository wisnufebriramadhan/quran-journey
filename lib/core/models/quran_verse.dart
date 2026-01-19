class QuranVerse {
  final int surah;
  final int ayah;
  final String text;

  QuranVerse({
    required this.surah,
    required this.ayah,
    required this.text,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    final parts = (json['verse_key'] as String).split(':');

    return QuranVerse(
      surah: int.parse(parts[0]),
      ayah: int.parse(parts[1]),
      text: json['text_uthmani'],
    );
  }
}
