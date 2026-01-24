import 'package:adhan/adhan.dart';
import '../../settings/data/settings_model.dart';

class PrayerTimeService {
  static PrayerTimes getPrayerTimes({
    required double latitude,
    required double longitude,
    required SettingsModel settings,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = _paramsFromSettings(settings);

    // ⏱️ Manual Offset (slider -2 s/d +2)
    params.adjustments.fajr = settings.fajrOffset;
    params.adjustments.dhuhr = settings.dhuhrOffset;
    params.adjustments.asr = settings.asrOffset;
    params.adjustments.maghrib = settings.maghribOffset;
    params.adjustments.isha = settings.ishaOffset;

    return PrayerTimes.today(coordinates, params);
  }

  static CalculationParameters _paramsFromSettings(
    SettingsModel settings,
  ) {
    switch (settings.prayerMethod) {
      case PrayerMethodType.kemenag:
        // 🇮🇩 KEMENAG (paling umum Indonesia)
        return CalculationMethod.singapore.getParameters();

      case PrayerMethodType.mwl:
        return CalculationMethod.muslim_world_league.getParameters();

      case PrayerMethodType.sihat:
        return _sihatIndonesiaParams(); // ✅ BARU
    }
  }

  /// 🏥 Metode SIHAT Indonesia (Custom)
  static CalculationParameters _sihatIndonesiaParams() {
    final params = CalculationParameters(
      fajrAngle: 20.0,
      ishaAngle: null, // ❌ JANGAN PAKAI ANGLE
      method: CalculationMethod.other,
    );

    params.madhab = Madhab.shafi;
    params.highLatitudeRule = HighLatitudeRule.middle_of_the_night;

    // 🌇 Maghrib = sunset murni
    params.maghribAngle = null;

    // 🌙 Isya = Maghrib + 90 menit (INI KUNCINYA)
    params.ishaInterval = 90;

    return params;
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
