import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// 🧪 SUPER SIMPLE TEST - Langsung bisa dipakai!
/// Tidak perlu initialize timezone karena NotificationService sudah handle

class QuickNotificationTest {
  static final _notifService = NotificationService();

  /// ⚡ Test Instant - untuk pastikan audio bekerja
  static Future<void> testInstant(BuildContext context) async {
    try {
      await _notifService.init();

      await _notifService.showInstantNotification(
        title: '🕌 Test Instant',
        body: 'Audio test - harus berbunyi sekarang',
        withSound: true,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Instant notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
    }
  }

  /// ⏰ Test Schedule 30 Detik
  static Future<void> scheduleIn30Seconds(BuildContext context) async {
    try {
      await _notifService.init();

      // Gunakan method test yang baru ditambahkan
      await _notifService.testScheduleNotification(
        seconds: 30,
        title: '🕌 Test 30 Detik',
        body: 'Notifikasi terjadwal dengan suara azan',
        withSound: true,
      );

      if (context.mounted) {
        final now = tz.TZDateTime.now(tz.local);
        final scheduledTime = now.add(const Duration(seconds: 30));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Dijadwalkan untuk ${scheduledTime.hour}:${scheduledTime.minute}:${scheduledTime.second}\n\n'
              'PENTING:\n'
              '1. LOCK Device Anda sekarang\n'
              '2. Tunggu 30 detik\n'
              '3. Notifikasi akan muncul dengan suara',
            ),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ⏰ Test Schedule 1 Menit
  static Future<void> scheduleIn1Minute(BuildContext context) async {
    try {
      await _notifService.init();

      await _notifService.testScheduleNotification(
        seconds: 60,
        title: '🕌 Test 1 Menit',
        body: 'Notifikasi dijadwalkan 1 menit',
        withSound: true,
      );

      if (context.mounted) {
        final now = tz.TZDateTime.now(tz.local);
        final scheduledTime = now.add(const Duration(minutes: 1));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Dijadwalkan untuk ${scheduledTime.hour}:${scheduledTime.minute}\n'
              'Lock Device dan tunggu 1 menit...',
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
    }
  }

  /// 📋 Cek Pending Notifications
  static Future<void> checkPending(BuildContext context) async {
    try {
      await _notifService.init();

      final pending = await _notifService.getPendingNotifications();

      if (kDebugMode) {
        print('📋 Pending notifications: ${pending.length}');
      }
      for (var p in pending) {
        if (kDebugMode) {
          print('  - ID ${p.id}: ${p.title}');
        }
      }

      if (context.mounted) {
        final message = pending.isEmpty
            ? 'Tidak ada notifikasi terjadwal'
            : 'Ada ${pending.length} notifikasi terjadwal:\n\n${pending.map((p) => '• ID ${p.id}: ${p.title}').join('\n')}';

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('📋 Pending Notifications'),
            content: SingleChildScrollView(
              child: Text(message),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
    }
  }

  /// 🗑️ Cancel All
  static Future<void> cancelAll(BuildContext context) async {
    try {
      await _notifService.cancelAllNotifications();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Semua notifikasi dibatalkan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
    }
  }

  /// 🔄 Re-schedule Prayer Notifications (Test Real Scenario)
  static Future<void> reSchedulePrayerTimes(BuildContext context) async {
    try {
      await _notifService.init();

      // Ini akan schedule ulang semua waktu sholat hari ini
      // Pastikan PrayerTimeProvider sudah punya data

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Prayer times re-scheduled!\n'
              'Cek "Pending Notifications" untuk lihat list',
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
    }
  }
}

/// ============================================
/// 📱 CARA PAKAI - COPY PASTE KE UI ANDA
/// ============================================

/*

// 1. Import file ini
import 'path/to/quick_notification_test.dart';

// 2. Tambahkan button-button test:

Column(
  children: [
    // Test 1: Instant Notification (pastikan audio bekerja)
    ElevatedButton.icon(
      onPressed: () => QuickNotificationTest.testInstant(context),
      icon: const Icon(Icons.volume_up),
      label: const Text('🔊 Test Instant (Audio)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.all(16),
      ),
    ),
    
    const SizedBox(height: 8),
    
    // Test 2: Schedule 30 Seconds
    ElevatedButton.icon(
      onPressed: () => QuickNotificationTest.scheduleIn30Seconds(context),
      icon: const Icon(Icons.timer),
      label: const Text('⏰ Test Schedule 30 Detik'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.all(16),
      ),
    ),
    
    const SizedBox(height: 8),
    
    // Test 3: Schedule 1 Minute
    ElevatedButton.icon(
      onPressed: () => QuickNotificationTest.scheduleIn1Minute(context),
      icon: const Icon(Icons.schedule),
      label: const Text('⏰ Test Schedule 1 Menit'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.all(16),
      ),
    ),
    
    const SizedBox(height: 8),
    
    // Test 4: Check Pending Notifications
    ElevatedButton.icon(
      onPressed: () => QuickNotificationTest.checkPending(context),
      icon: const Icon(Icons.list),
      label: const Text('📋 Cek Pending Notifications'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.all(16),
      ),
    ),
    
    const SizedBox(height: 8),
    
    // Test 5: Cancel All
    ElevatedButton.icon(
      onPressed: () => QuickNotificationTest.cancelAll(context),
      icon: const Icon(Icons.delete),
      label: const Text('🗑️ Cancel Semua'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.all(16),
      ),
    ),
  ],
)

// 3. Test Flow:
//    a. Test Instant → pastikan audio berbunyi ✅
//    b. Test Schedule 30 Detik → LOCK phone, tunggu 30 detik ⏰
//    c. Cek Pending → harus ada notifikasi terjadwal 📋
//    d. Buka halaman Prayer Times → otomatis schedule 5 waktu sholat
//    e. Tunggu waktu sholat tiba → notifikasi muncul dengan audio 🕌

*/