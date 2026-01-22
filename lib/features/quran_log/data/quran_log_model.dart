class QuranLog {
  final String date;
  final String surah;
  final int ayatFrom;
  final int ayatTo;
  final int? duration; // ✅ nullable

  QuranLog({
    required this.date,
    required this.surah,
    required this.ayatFrom,
    required this.ayatTo,
    this.duration,
  });

  factory QuranLog.fromJson(Map<String, dynamic> json) {
    return QuranLog(
      date: json['date'],
      surah: json['surah'],
      ayatFrom: json['ayat_from'],
      ayatTo: json['ayat_to'],
      duration: json['duration'], // boleh null
    );
  }
}
