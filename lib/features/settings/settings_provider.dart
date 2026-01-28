import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyPrayerMethod = 'prayer_method';
  static const _keyHijriMethod = 'hijri_method';
  static const _keyHijriOffset = 'hijri_offset';

  static const _keyFajrOffset = 'fajr_offset';
  static const _keyDhuhrOffset = 'dhuhr_offset';
  static const _keyAsrOffset = 'asr_offset';
  static const _keyMaghribOffset = 'maghrib_offset';
  static const _keyIshaOffset = 'isha_offset';

  SettingsModel _settings = const SettingsModel(
    prayerMethod: PrayerMethodType.sihat,
    hijriMethod: HijriMethodType.kuwait,
  );

  SettingsModel get settings => _settings;

  // =========================
  // LOAD
  // =========================
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _settings = SettingsModel(
      prayerMethod: PrayerMethodType.values[
          prefs.getInt(_keyPrayerMethod) ?? 0],
      hijriMethod:
          HijriMethodType.values[prefs.getInt(_keyHijriMethod) ?? 0],
      hijriOffset: prefs.getInt(_keyHijriOffset) ?? 0,
      fajrOffset: prefs.getInt(_keyFajrOffset) ?? 0,
      dhuhrOffset: prefs.getInt(_keyDhuhrOffset) ?? 0,
      asrOffset: prefs.getInt(_keyAsrOffset) ?? 0,
      maghribOffset: prefs.getInt(_keyMaghribOffset) ?? 0,
      ishaOffset: prefs.getInt(_keyIshaOffset) ?? 0,
    );

    notifyListeners();
  }

  // =========================
  // SETTERS
  // =========================
  Future<void> setPrayerMethod(PrayerMethodType method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrayerMethod, method.index);

    _settings = _settings.copyWith(prayerMethod: method);
    notifyListeners();
  }

  Future<void> setHijriMethod(HijriMethodType method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHijriMethod, method.index);

    _settings = _settings.copyWith(hijriMethod: method);
    notifyListeners();
  }

  Future<void> setHijriOffset(int offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHijriOffset, offset);

    _settings = _settings.copyWith(hijriOffset: offset);
    notifyListeners();
  }

  // =========================
  // OFFSET SHOLAT
  // =========================
  Future<void> setPrayerOffset({
    int? fajr,
    int? dhuhr,
    int? asr,
    int? maghrib,
    int? isha,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (fajr != null) await prefs.setInt(_keyFajrOffset, fajr);
    if (dhuhr != null) await prefs.setInt(_keyDhuhrOffset, dhuhr);
    if (asr != null) await prefs.setInt(_keyAsrOffset, asr);
    if (maghrib != null) await prefs.setInt(_keyMaghribOffset, maghrib);
    if (isha != null) await prefs.setInt(_keyIshaOffset, isha);

    _settings = _settings.copyWith(
      fajrOffset: fajr,
      dhuhrOffset: dhuhr,
      asrOffset: asr,
      maghribOffset: maghrib,
      ishaOffset: isha,
    );

    notifyListeners();
  }
}
