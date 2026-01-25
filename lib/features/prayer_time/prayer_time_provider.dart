import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

import '../../core/services/location_service.dart';
import '../../features/settings/data/settings_model.dart';
import 'data/prayer_time_service.dart';
import 'data/notification_service.dart';

class PrayerTimeProvider extends ChangeNotifier {
  // ================= DATA =================
  PrayerTimes? prayerTimes;
  Prayer? nextPrayer;

  String? city;
  String? country;
  String? hijriDate;

  SettingsModel? _settings;

  bool loading = false;
  String? error;

  final NotificationService _notificationService = NotificationService();

  // ================= SETTINGS =================
  void updateSettings(SettingsModel settings) {
    _settings = settings;
    loadPrayerTimes();
  }

  // ================= LOAD PRAYER TIMES =================
  Future<void> loadPrayerTimes() async {
    if (_settings == null) return;

    try {
      loading = true;
      error = null;

      final location = await LocationService.getCurrentLocation();

      city = location.city;
      country = location.country;

      prayerTimes = PrayerTimeService.getPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        settings: _settings!,
      );

      final next = prayerTimes!.nextPrayer();
      nextPrayer = next == Prayer.none ? Prayer.fajr : next;

      await _scheduleNotifications();
      await NotificationService().schedulePrayerNotifications(prayerTimes!);
    } catch (e) {
      error = 'Gagal memuat waktu sholat';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ================= SCHEDULE =================
  Future<void> _scheduleNotifications() async {
    if (prayerTimes == null) return;

    try {
      await _notificationService.initialize();
      final allowed = await _notificationService.requestPermission();

      if (allowed) {
        await _notificationService.schedulePrayerNotifications(prayerTimes!);
      }
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  // ================= PER-PRAYER TOGGLE =================
  Future<bool> isPrayerEnabled(Prayer prayer) async {
    return await _notificationService.getPrayerNotificationEnabled(prayer);
  }

  Future<void> togglePrayer(
    Prayer prayer,
    bool enabled,
  ) async {
    await _notificationService.setPrayerNotificationEnabled(prayer, enabled);

    if (prayerTimes != null) {
      await _notificationService.schedulePrayerNotifications(prayerTimes!);
    }

    notifyListeners();
  }

  // ================= NEXT PRAYER TIME =================
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

  // ================= NEXT PRAYER NAME =================
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

  // ================= REMAINING TIME =================
  Duration get remainingToNextPrayer {
    if (nextPrayerTime == null) return Duration.zero;
    return nextPrayerTime!.difference(DateTime.now());
  }
}
