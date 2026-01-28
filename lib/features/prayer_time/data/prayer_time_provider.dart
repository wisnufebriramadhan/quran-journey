import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../core/services/location_service.dart';
import '../../settings/data/settings_model.dart';
import 'prayer_time_service.dart';
import 'notification_service.dart';

class PrayerTimeProvider extends ChangeNotifier {
  // ================= DATA =================
  PrayerTimes? prayerTimes;
  Prayer? nextPrayer;

  String? city;
  String? country;
  String? hijriDate;

  SettingsModel _settings = const SettingsModel(
    prayerMethod: PrayerMethodType.sihat, // ✅ DEFAULT SIHAT
    hijriMethod: HijriMethodType.kuwait,
    fajrOffset: 0,
    dhuhrOffset: 0,
    asrOffset: 0,
    maghribOffset: 0,
    ishaOffset: 0,
  );

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
    try {
      loading = true;
      error = null;
      notifyListeners();

      final location = await LocationService.getCurrentLocation();

      city = location.city;
      country = location.country;

      prayerTimes = PrayerTimeService.getPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        settings: _settings,
      );

      final next = prayerTimes!.nextPrayer();
      nextPrayer = next == Prayer.none ? Prayer.fajr : next;

      // ✅ Get Hijri Date with offset
      hijriDate = _getHijriDate();

      await _scheduleNotifications();
    } catch (e) {
      error = 'Gagal memuat waktu sholat: $e';
      debugPrint('Error loading prayer times: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ================= GET HIJRI DATE =================
  String _getHijriDate() {
    try {
      final hijri = HijriCalendar.now();
      
      // Apply offset from settings
      final offset = _settings.hijriOffset;
      if (offset != 0) {
        hijri.hDay = hijri.hDay + offset;
      }

      return hijri.toFormat("dd MMMM yyyy");
    } catch (e) {
      debugPrint('Error getting Hijri date: $e');
      return '-';
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

  // ================= REFRESH =================
  Future<void> refresh() async {
    await loadPrayerTimes();
  }
}