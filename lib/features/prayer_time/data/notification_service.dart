import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:adhan/adhan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification IDs
  static const int fajrId = 1;
  static const int dhuhrId = 2;
  static const int asrId = 3;
  static const int maghribId = 4;
  static const int ishaId = 5;

  // SharedPreferences Keys
  static const String _enabledKey = 'notifications_enabled';
  static const String _fajrEnabledKey = 'fajr_notification_enabled';
  static const String _dhuhrEnabledKey = 'dhuhr_notification_enabled';
  static const String _asrEnabledKey = 'asr_notification_enabled';
  static const String _maghribEnabledKey = 'maghrib_notification_enabled';
  static const String _ishaEnabledKey = 'isha_notification_enabled';

  // Audio file name (tanpa extension)
  static const String _audioFile = 'audio';

  Future<void> init() async {
    await initialize();
  }

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();

    _initialized = true;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    const soundChannel = AndroidNotificationChannel(
      'prayer_sound_channel',
      'Prayer With Sound',
      description: 'Notifikasi waktu sholat dengan suara',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound(_audioFile),
    );

    const silentChannel = AndroidNotificationChannel(
      'prayer_silent_channel',
      'Prayer Silent',
      description: 'Notifikasi waktu sholat tanpa suara',
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
      sound: null,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(soundChannel);
      await androidPlugin.createNotificationChannel(silentChannel);
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Schedule prayer notifications for the day
  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_enabledKey) ?? true;

    if (!isEnabled) {
      await cancelAllNotifications();
      return;
    }

    await cancelAllNotifications();

    await _schedulePrayer(
      id: fajrId,
      time: prayerTimes.fajr,
      title: '🌙 Waktu Subuh Tiba',
      body: 'Saatnya menunaikan sholat Subuh',
      prefKey: _fajrEnabledKey,
    );

    await _schedulePrayer(
      id: dhuhrId,
      time: prayerTimes.dhuhr,
      title: '☀️ Waktu Dzuhur Tiba',
      body: 'Saatnya menunaikan sholat Dzuhur',
      prefKey: _dhuhrEnabledKey,
    );

    await _schedulePrayer(
      id: asrId,
      time: prayerTimes.asr,
      title: '🌤️ Waktu Ashar Tiba',
      body: 'Saatnya menunaikan sholat Ashar',
      prefKey: _asrEnabledKey,
    );

    await _schedulePrayer(
      id: maghribId,
      time: prayerTimes.maghrib,
      title: '🌆 Waktu Maghrib Tiba',
      body: 'Saatnya menunaikan sholat Maghrib',
      prefKey: _maghribEnabledKey,
    );

    await _schedulePrayer(
      id: ishaId,
      time: prayerTimes.isha,
      title: '🌙 Waktu Isya Tiba',
      body: 'Saatnya menunaikan sholat Isya',
      prefKey: _ishaEnabledKey,
    );
  }

  /// Schedule individual prayer notification
  Future<void> _schedulePrayer({
    required int id,
    required DateTime time,
    required String title,
    required String body,
    required String prefKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final soundEnabled = prefs.getBool(prefKey) ?? true;

    final scheduledTime = tz.TZDateTime.from(time, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduleTime;
    if (scheduledTime.isBefore(now)) {
      scheduleTime = scheduledTime.add(const Duration(days: 1));
    } else {
      scheduleTime = scheduledTime;
    }

    final channelId =
        soundEnabled ? 'prayer_sound_channel' : 'prayer_silent_channel';
    final channelName = soundEnabled ? 'Prayer With Sound' : 'Prayer Silent';

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduleTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'Notifikasi waktu sholat',
            importance: Importance.high,
            priority: Priority.high,
            playSound: soundEnabled,
            sound: soundEnabled
                ? const RawResourceAndroidNotificationSound(_audioFile)
                : null,
            enableVibration: soundEnabled,
            icon: '@mipmap/ic_launcher',
            styleInformation: const BigTextStyleInformation(''),
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: soundEnabled,
            sound: soundEnabled ? 'audio.mp3' : null,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Show instant notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Notifikasi instan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      details,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Enable/disable all notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  /// Check if notifications are enabled
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  /// Enable/disable notification for specific prayer
  Future<void> setPrayerNotificationEnabled(Prayer prayer, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPrayerPreferenceKey(prayer);
    if (key != null) {
      await prefs.setBool(key, enabled);
    }
  }

  /// Check if notification is enabled for specific prayer
  Future<bool> getPrayerNotificationEnabled(Prayer prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPrayerPreferenceKey(prayer);
    return key != null ? (prefs.getBool(key) ?? true) : false;
  }

  /// Get preference key for prayer
  String? _getPrayerPreferenceKey(Prayer prayer) {
    return switch (prayer) {
      Prayer.fajr => _fajrEnabledKey,
      Prayer.dhuhr => _dhuhrEnabledKey,
      Prayer.asr => _asrEnabledKey,
      Prayer.maghrib => _maghribEnabledKey,
      Prayer.isha => _ishaEnabledKey,
      _ => null,
    };
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
  }

  /// Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
