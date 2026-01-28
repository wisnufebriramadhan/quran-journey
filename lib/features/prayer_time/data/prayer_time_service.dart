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

    // ⏱️ Manual Offset (slider dari settings)
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
        return _sihatIndonesiaParams(); // ✅ Metode SIHAT
    }
  }

  /// 🏥 Metode SIHAT Indonesia (Custom)
  /// Sesuai dengan screenshot: Fajr 04:33, Dhuhr 12:07, Asr 15:29, Maghrib 18:19, Isha 19:33
  static CalculationParameters _sihatIndonesiaParams() {
    final params = CalculationParameters(
      fajrAngle: 20.0, // ✅ Subuh: -20°
      ishaAngle: 18.0, // ✅ Isya: -18°
      method: CalculationMethod.other,
    );

    params.madhab = Madhab.shafi; // ✅ Mazhab Shafi untuk Indonesia
    params.highLatitudeRule = HighLatitudeRule.middle_of_the_night;

    // Tidak perlu ishaInterval karena sudah pakai ishaAngle
    return params;
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
