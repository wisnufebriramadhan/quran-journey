class SurahNames {
  static const List<String> names = [
    'Al-Fatihah',
    'Al-Baqarah',
    'Ali Imran',
    'An-Nisa',
    'Al-Maidah',
    'Al-An’am',
    'Al-A’raf',
    'Al-Anfal',
    'At-Taubah',
    'Yunus',
    'Hud',
    'Yusuf',
    'Ar-Ra’d',
    'Ibrahim',
    'Al-Hijr',
    'An-Nahl',
    'Al-Isra',
    'Al-Kahf',
    'Maryam',
    'Ta-Ha',
    // 👉 nanti bisa diteruskan sampai 114
  ];

  /// helper aman (biar ga out of range)
  static String byNumber(int surah) {
    if (surah < 1 || surah > names.length) {
      return 'Surah $surah';
    }
    return names[surah - 1];
  }
}
