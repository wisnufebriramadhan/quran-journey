enum PrayerMethodType {
  kemenag,
  mwl,
  sihat,
}

enum HijriMethodType {
  kuwait,
  ummulQura,
}

class SettingsModel {
  final PrayerMethodType prayerMethod;
  final HijriMethodType hijriMethod;

  // 🔥 OFFSET MENIT SHOLAT
  final int fajrOffset;
  final int dhuhrOffset;
  final int asrOffset;
  final int maghribOffset;
  final int ishaOffset;

  // 🔥 OFFSET HIJRIAH
  final int hijriOffset;

  const SettingsModel({
    required this.prayerMethod,
    required this.hijriMethod,
    this.fajrOffset = 2,
    this.dhuhrOffset = 2,
    this.asrOffset = 2,
    this.maghribOffset = 2,
    this.ishaOffset = 2,
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
}
