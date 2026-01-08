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

    // Penyesuaian hari Hijriah (slider -2 s/d +2)
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
        // PALING COCOK UNTUK INDONESIA
        return CalculationMethod.singapore.getParameters();

      case PrayerMethodType.mwl:
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
