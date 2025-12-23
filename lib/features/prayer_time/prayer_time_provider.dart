import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../../core/services/location_service.dart';
import 'data/prayer_time_service.dart';

class PrayerTimeProvider extends ChangeNotifier {
  PrayerTimes? prayerTimes;
  Prayer? nextPrayer;

  String? city;
  String? country;

  bool loading = false;
  String? error;

  Future<void> loadPrayerTimes() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final position = await LocationService.getCurrentPosition();

      final placemark = await LocationService.getPlacemark(position);
      city = placemark.locality ?? placemark.subAdministrativeArea;
      country = placemark.country;

      prayerTimes = PrayerTimeService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      nextPrayer = prayerTimes!.nextPrayer();
    } catch (e) {
      error = 'Gagal memuat waktu sholat';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
