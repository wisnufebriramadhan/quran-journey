import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String _groupId = 'group.com.wisnufebri.quran.app';
  static const String _androidPrayerWidgetName = 'PrayerWidget';
  static const String _androidMurattalWidgetName = 'MurattalWidget';

  static Future<void> updatePrayerWidget({
    required String name,
    required String time,
    required String city,
    required String hijri,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('next_prayer_name', name);
      await HomeWidget.saveWidgetData<String>('next_prayer_time', time);
      await HomeWidget.saveWidgetData<String>('city', city);
      await HomeWidget.saveWidgetData<String>('hijri', hijri);
      
      await HomeWidget.updateWidget(
        name: _androidPrayerWidgetName,
        androidName: _androidPrayerWidgetName,
      );
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> updateMurattalWidget({
    required String surahName,
    required bool isPlaying,
    required double progress, // 0.0 to 1.0
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('surah_name', surahName);
      await HomeWidget.saveWidgetData<bool>('is_playing', isPlaying);
      await HomeWidget.saveWidgetData<int>('playback_progress', (progress * 100).toInt());
      
      await HomeWidget.updateWidget(
        name: _androidMurattalWidgetName,
        androidName: _androidMurattalWidgetName,
      );
    } catch (e) {
      // Silently fail
    }
  }
}
