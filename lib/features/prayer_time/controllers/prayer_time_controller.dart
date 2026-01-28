import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../data/notification_service.dart';
import '../data/prayer_time_provider.dart';

/// 🎯 Prayer Time Controller
/// Handles all business logic, state management, and notification handling
class PrayerTimeController with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();
  final BuildContext context;

  // Notification settings state
  bool fajrEnabled = true;
  bool dhuhrEnabled = true;
  bool asrEnabled = true;
  bool maghribEnabled = true;
  bool ishaEnabled = true;

  // Callbacks
  final VoidCallback? onStateChanged;

  PrayerTimeController({
    required this.context,
    this.onStateChanged,
  });

  // ==================== LIFECYCLE ====================

  /// Initialize controller
  Future<void> initialize() async {
    if (kDebugMode) {
      print('🔄 [CONTROLLER] Initializing...');
    }

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Load prayer times
    await _loadPrayerTimes();

    // Auto-schedule notifications
    await scheduleNotificationsIfNeeded();

    // Load notification settings
    await loadNotificationSettings();

    if (kDebugMode) {
      print('✅ [CONTROLLER] Initialization complete');
    }
  }

  /// Dispose controller
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (kDebugMode) {
      print('🗑️ [CONTROLLER] Disposed');
    }
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      print('🔄 [LIFECYCLE] App state: $state');
    }

    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print('✅ [LIFECYCLE] App resumed, re-scheduling...');
      }
      scheduleNotificationsIfNeeded();
    }
  }

  // ==================== DATA LOADING ====================

  /// Load prayer times from provider
  Future<void> _loadPrayerTimes() async {
    try {
      final provider = _getProvider();
      await provider.loadPrayerTimes();
      if (kDebugMode) {
        print('✅ [CONTROLLER] Prayer times loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CONTROLLER] Error loading prayer times: $e');
      }
    }
  }

  /// Load notification settings for all prayers
  Future<void> loadNotificationSettings() async {
    try {
      fajrEnabled =
          await _notificationService.getPrayerNotificationEnabled(Prayer.fajr);
      dhuhrEnabled =
          await _notificationService.getPrayerNotificationEnabled(Prayer.dhuhr);
      asrEnabled =
          await _notificationService.getPrayerNotificationEnabled(Prayer.asr);
      maghribEnabled = await _notificationService
          .getPrayerNotificationEnabled(Prayer.maghrib);
      ishaEnabled =
          await _notificationService.getPrayerNotificationEnabled(Prayer.isha);

      _notifyStateChanged();
      if (kDebugMode) {
        print('✅ [CONTROLLER] Notification settings loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CONTROLLER] Error loading notification settings: $e');
      }
    }
  }

  // ==================== NOTIFICATION MANAGEMENT ====================

  /// Schedule notifications if prayer times exist
  Future<void> scheduleNotificationsIfNeeded() async {
    try {
      final provider = _getProvider();

      if (provider.prayerTimes == null) {
        if (kDebugMode) {
          print('⚠️ [CONTROLLER] Prayer times null, reloading...');
        }
        await provider.loadPrayerTimes();
      }

      if (provider.prayerTimes != null) {
        if (kDebugMode) {
          print('🔄 [CONTROLLER] Scheduling notifications...');
        }

        await _notificationService.schedulePrayerNotifications(
          provider.prayerTimes!,
        );

        if (kDebugMode) {
          print('✅ [CONTROLLER] Notifications scheduled');
        }
        await _notificationService.printPendingNotifications();
      } else {
        if (kDebugMode) {
          print('❌ [CONTROLLER] Cannot schedule - prayer times still null');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CONTROLLER] Error scheduling notifications: $e');
      }
    }
  }

  /// Toggle notification for specific prayer
  Future<void> togglePrayerNotification(Prayer prayer, bool value) async {
    try {
      await _notificationService.setPrayerNotificationEnabled(prayer, value);

      // Update local state
      _updateNotificationState(prayer, value);

      // Re-schedule notifications
      await scheduleNotificationsIfNeeded();

      // Additional re-schedule to ensure it's applied
      final provider = _getProvider();
      if (provider.prayerTimes != null) {
        await _notificationService.schedulePrayerNotifications(
          provider.prayerTimes!,
        );
        if (kDebugMode) {
          print('✅ [CONTROLLER] Notifications re-scheduled after toggle');
        }
      }

      _notifyStateChanged();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CONTROLLER] Error toggling prayer notification: $e');
      }
    }
  }

  /// Re-schedule all prayer notifications manually
  Future<void> reScheduleNotifications() async {
    final provider = _getProvider();
    if (provider.prayerTimes != null) {
      await _notificationService.schedulePrayerNotifications(
        provider.prayerTimes!,
      );
      if (kDebugMode) {
        print('✅ [CONTROLLER] Manual re-schedule complete');
      }
    }
  }

  // ==================== STATE HELPERS ====================

  /// Check if notification is enabled for prayer
  bool isNotificationEnabled(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'subuh':
        return fajrEnabled;
      case 'dzuhur':
        return dhuhrEnabled;
      case 'ashar':
        return asrEnabled;
      case 'maghrib':
        return maghribEnabled;
      case 'isya':
        return ishaEnabled;
      default:
        return false;
    }
  }

  /// Get Prayer enum from Indonesian name
  Prayer? getPrayerFromName(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'subuh':
        return Prayer.fajr;
      case 'dzuhur':
        return Prayer.dhuhr;
      case 'ashar':
        return Prayer.asr;
      case 'maghrib':
        return Prayer.maghrib;
      case 'isya':
        return Prayer.isha;
      default:
        return null;
    }
  }

  /// Get prayer icon based on prayer name
  IconData getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'subuh':
        return Icons.wb_twilight;
      case 'dzuhur':
        return Icons.wb_sunny;
      case 'ashar':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.wb_twilight_outlined;
      case 'isya':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  // ==================== PRIVATE HELPERS ====================

  /// Update notification state for specific prayer
  void _updateNotificationState(Prayer prayer, bool value) {
    switch (prayer) {
      case Prayer.fajr:
        fajrEnabled = value;
        break;
      case Prayer.dhuhr:
        dhuhrEnabled = value;
        break;
      case Prayer.asr:
        asrEnabled = value;
        break;
      case Prayer.maghrib:
        maghribEnabled = value;
        break;
      case Prayer.isha:
        ishaEnabled = value;
        break;
      default:
        break;
    }
  }

  /// Get provider instance
  PrayerTimeProvider _getProvider() {
    return context.read<PrayerTimeProvider>();
  }

  /// Notify state changed
  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  // ==================== GETTERS ====================

  NotificationService get notificationService => _notificationService;
}
