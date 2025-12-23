import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class PrayerTimeService {
  static PrayerTimes getPrayerTimes({
    required double latitude,
    required double longitude,
  }) {
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final coordinates = Coordinates(latitude, longitude);
    final date = DateComponents.from(DateTime.now());

    return PrayerTimes(coordinates, date, params);
  }

  static String formatTime(DateTime time) {
    return DateFormat.Hm().format(time);
  }
}
