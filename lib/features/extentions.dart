 // ======= KONVERSI GREGORIAN -> HIJRI (PERKIRAAN) =======
  String getHijriToday() {
    final now = DateTime.now();

    // Algoritma sederhana (cukup akurat untuk tampilan UI)
    int jd = _gregorianToJulianDay(now.year, now.month, now.day);
    List<int> hijri = _julianDayToHijri(jd);

    const hijriMonths = [
      'Muharram',
      'Safar',
      'Rabiul Awal',
      'Rabiul Akhir',
      'Jumadil Awal',
      'Jumadil Akhir',
      'Rajab',
      'Sya’ban',
      'Ramadhan',
      'Syawal',
      'Dzulqa’dah',
      'Dzulhijjah',
    ];

    return '${hijri[2]} ${hijriMonths[hijri[1] - 1]} ${hijri[0]} H';
  }

  int _gregorianToJulianDay(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    int a = y ~/ 100;
    int b = 2 - a + (a ~/ 4);
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524;
  }

  List<int> _julianDayToHijri(int jd) {
    int l = jd - 1948440 + 10632;
    int n = ((l - 1) ~/ 10631).floor();
    l = l - 10631 * n + 354;
    int j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    int m = (24 * l ~/ 709).floor();
    int d = l - (709 * m ~/ 24).floor();
    int y = 30 * n + j - 30;

    return [y, m, d];
  }

    String formatMasehi(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  // Daftar qari yang tersedia
  final List<Map<String, String>> qariList = [
    {'id': 'abdullaah_3awwaad_al-juhaynee', 'name': 'Abdullah Awwad Al-Juhany'},
    {'id': 'abdul_basit_murattal', 'name': 'Abdul Basit (Murattal)'},
    {'id': 'abdurrahmaan_as-sudays', 'name': 'Abdurrahman As-Sudais'},
    {'id': 'mishaari_raashid_al_3afaasee', 'name': 'Mishary Rashid Alafasy'},
    {'id': 'sa3d_al-ghaamidi', 'name': 'Saad Al-Ghamdi'},
    {'id': 'ahmed_ibn_3ali_al-3ajamy', 'name': 'Ahmed Al-Ajamy'},
    {'id': 'mahmoud_khalil_al-husaree', 'name': 'Mahmoud Khalil Al-Hussary'},
  ];

  // Daftar nama surah
  final List<String> surahNames = [
    'Al-Fatihah', 'Al-Baqarah', 'Ali \'Imran', 'An-Nisa\'', 'Al-Ma\'idah',
    'Al-An\'am', 'Al-A\'raf', 'Al-Anfal', 'At-Tawbah', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Ra\'d', 'Ibrahim', 'Al-Hijr',
    'An-Nahl', 'Al-Isra\'', 'Al-Kahf', 'Maryam', 'Ta-Ha',
    'Al-Anbiya\'', 'Al-Hajj', 'Al-Mu\'minun', 'An-Nur', 'Al-Furqan',
    'Ash-Shu\'ara\'', 'An-Naml', 'Al-Qasas', 'Al-\'Ankabut', 'Ar-Rum',
    'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba\'', 'Fatir',
    'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman',
    'Al-Waqi\'ah', 'Al-Hadid', 'Al-Mujadilah', 'Al-Hashr', 'Al-Mumtahanah',
    'As-Saff', 'Al-Jumu\'ah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq',
    'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Ma\'arij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah',
    'Al-Insan', 'Al-Mursalat', 'An-Naba\'', 'An-Nazi\'at', 'Abasa',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj',
    'At-Tariq', 'Al-A\'la', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Layl', 'Ad-Duha', 'Ash-Sharh', 'At-Tin',
    'Al-\'Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-\'Adiyat',
    'Al-Qari\'ah', 'At-Takathur', 'Al-\'Asr', 'Al-Humazah', 'Al-Fil',
    'Quraysh', 'Al-Ma\'un', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
  ];