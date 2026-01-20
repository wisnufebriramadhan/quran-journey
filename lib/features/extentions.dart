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
  