List<String> generateSurahAudioUrls({
  required int surah,
  required int totalAyah,
}) {
  return List.generate(totalAyah, (index) {
    final ayah = index + 1;
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');

    return 'https://everyayah.com/data/Alafasy_128kbps/$s$a.mp3';
  });
}
