enum PrayerMethodType {
  kemenag,
  mwl,
  sihat, // ✅ Sudah ada
}

enum HijriMethodType {
  kuwait,
  ummulQura,
}

class SettingsModel {
  final PrayerMethodType prayerMethod;
  final HijriMethodType hijriMethod;

  // Offset menit sholat
  final int fajrOffset;
  final int dhuhrOffset;
  final int asrOffset;
  final int maghribOffset;
  final int ishaOffset;

  // Offset hijriah
  final int hijriOffset;

  const SettingsModel({
    required this.prayerMethod,
    required this.hijriMethod,
    this.fajrOffset = 0,
    this.dhuhrOffset = 0,
    this.asrOffset = 0,
    this.maghribOffset = 0,
    this.ishaOffset = 0,
    this.hijriOffset = 0,
  });

  SettingsModel copyWith({
    PrayerMethodType? prayerMethod,
    HijriMethodType? hijriMethod,
    int? fajrOffset,
    int? dhuhrOffset,
    int? asrOffset,
    int? maghribOffset,
    int? ishaOffset,
    int? hijriOffset,
  }) {
    return SettingsModel(
      prayerMethod: prayerMethod ?? this.prayerMethod,
      hijriMethod: hijriMethod ?? this.hijriMethod,
      fajrOffset: fajrOffset ?? this.fajrOffset,
      dhuhrOffset: dhuhrOffset ?? this.dhuhrOffset,
      asrOffset: asrOffset ?? this.asrOffset,
      maghribOffset: maghribOffset ?? this.maghribOffset,
      ishaOffset: ishaOffset ?? this.ishaOffset,
      hijriOffset: hijriOffset ?? this.hijriOffset,
    );
  }

  // ✅ Helper untuk mendapatkan nama metode
  String get prayerMethodName {
    switch (prayerMethod) {
      case PrayerMethodType.kemenag:
        return 'Kemenag RI';
      case PrayerMethodType.mwl:
        return 'Muslim World League';
      case PrayerMethodType.sihat:
        return 'SIHAT Indonesia';
    }
  }

  String get hijriMethodName {
    switch (hijriMethod) {
      case HijriMethodType.kuwait:
        return 'Kuwait';
      case HijriMethodType.ummulQura:
        return 'Ummul Qura';
    }
  }
}
