import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

import '../../core/services/location_service.dart';
import '../../features/settings/data/settings_model.dart';
import 'data/prayer_time_service.dart';

class PrayerTimeProvider extends ChangeNotifier {
  PrayerTimes? prayerTimes;
  Prayer? nextPrayer;

  String? city;
  String? country;
  String? hijriDate;

  SettingsModel? _settings;

  bool loading = false;
  String? error;

  // 🔥 CONSTRUCTOR KOSONG (WAJIB)
  PrayerTimeProvider();

  // 🔥 DIPANGGIL DARI ProxyProvider
  void updateSettings(SettingsModel settings) {
    _settings = settings;
    loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    if (_settings == null) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final location = await LocationService.getCurrentLocation();

      city = location.city;
      country = location.country;

      prayerTimes = PrayerTimeService.getPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        settings: _settings!,
      );

      final next = prayerTimes!.nextPrayer();

      if (next == Prayer.none) {
        // 🔥 sudah lewat Isya → next Subuh BESOK
        nextPrayer = Prayer.fajr;
      } else {
        nextPrayer = next;
      }
    } catch (e) {
      error = 'Gagal memuat waktu sholat';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ================= NEXT PRAYER HELPERS =================

  DateTime? get nextPrayerTime {
    if (prayerTimes == null || nextPrayer == null) return null;

    switch (nextPrayer!) {
      case Prayer.fajr:
        return prayerTimes!.fajr;
      case Prayer.dhuhr:
        return prayerTimes!.dhuhr;
      case Prayer.asr:
        return prayerTimes!.asr;
      case Prayer.maghrib:
        return prayerTimes!.maghrib;
      case Prayer.isha:
        return prayerTimes!.isha;
      default:
        return null;
    }
  }

  String? get nextPrayerName {
    if (nextPrayer == null) return null;

    switch (nextPrayer!) {
      case Prayer.fajr:
        return 'Subuh';
      case Prayer.dhuhr:
        return 'Dzuhur';
      case Prayer.asr:
        return 'Ashar';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isya';
      default:
        return null;
    }
  }

  Duration get remainingToNextPrayer {
    if (nextPrayerTime == null) return Duration.zero;
    return nextPrayerTime!.difference(DateTime.now());
  }
}
