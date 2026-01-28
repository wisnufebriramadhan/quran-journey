import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:quran_tracker/features/prayer_time/widgets/notification_settings_sheet.dart';

// Imports
import 'data/prayer_time_provider.dart';
import 'data/prayer_time_service.dart';
import 'controllers/prayer_time_controller.dart';
import 'constants/prayer_time_constants.dart';
import 'painters/prayer_painters.dart';
import 'widgets/location_hijri_card.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_header_section.dart';
import 'widgets/prayer_item_card.dart';

// Debug (optional)
import 'widgets/quick_notification_test.dart';

/// 🕌 Prayer Time Page
/// Main page for displaying prayer times and managing notifications
class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage>
    with SingleTickerProviderStateMixin {
  // Controller
  late PrayerTimeController _controller;

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _controller = PrayerTimeController(
      context: context,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );

    // Initialize animations
    _initAnimations();

    // Initialize data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize animations
  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();

    // Loading State
    if (provider.loading) {
      return _buildLoadingScreen();
    }

    // Error State
    if (provider.error != null) {
      return _buildErrorScreen();
    }

    // No Data State
    if (provider.prayerTimes == null) {
      return _buildNoDataScreen();
    }

    // Main Content
    return _buildMainContent(provider);
  }

  /// Build main content
  Widget _buildMainContent(PrayerTimeProvider provider) {
    final pt = provider.prayerTimes!;
    final next = provider.nextPrayer;
    final hijri = provider.hijriDate;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PrayerTimeConstants.background,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Background with patterns
              _buildBackground(),

              // Scrollable content
              _buildScrollableContent(pt, next, hijri, provider),
            ],
          ),
        ),
      ),
    );
  }

  /// Build scrollable content
  Widget _buildScrollableContent(
    PrayerTimes pt,
    Prayer? next,
    String? hijri,
    PrayerTimeProvider provider,
  ) {
    return SingleChildScrollView(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  PrayerHeaderSection(
                    onDebugLongPress: _showDebugMenu,
                  ),
                  const SizedBox(height: 28),

                  // Location & Hijri Card
                  LocationHijriCard(
                    city: provider.city,
                    country: provider.country,
                    hijriDate: hijri,
                  ),
                  const SizedBox(height: 16),

                  // Next Prayer Card
                  NextPrayerCard(
                    prayerName: next?.name ?? '-',
                    prayerTime: _formatNextPrayerTime(pt, next),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Prayer Times List
            _buildPrayerTimesList(pt, next),
          ],
        ),
      ),
    );
  }

  /// Build prayer times list section
  Widget _buildPrayerTimesList(PrayerTimes pt, Prayer? next) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PrayerTimeConstants.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(PrayerTimeConstants.radiusHuge),
          topRight: Radius.circular(PrayerTimeConstants.radiusHuge),
        ),
      ),
      padding: const EdgeInsets.all(PrayerTimeConstants.spacingXXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Lengkap',
            style: PrayerTimeConstants.sectionTitle,
          ),
          const SizedBox(height: PrayerTimeConstants.spacingXLarge),

          // Prayer Items
          _buildPrayerItem('Subuh', pt.fajr, next?.name == 'Fajr'),
          _buildPrayerItem('Dzuhur', pt.dhuhr, next?.name == 'Dhuhr'),
          _buildPrayerItem('Ashar', pt.asr, next?.name == 'Asr'),
          _buildPrayerItem('Maghrib', pt.maghrib, next?.name == 'Maghrib'),
          _buildPrayerItem('Isya', pt.isha, next?.name == 'Isha'),

          const SizedBox(height: PrayerTimeConstants.spacingLarge),
        ],
      ),
    );
  }

  /// Build individual prayer item
  Widget _buildPrayerItem(String label, DateTime time, bool isNext) {
    return PrayerItemCard(
      prayerName: label,
      prayerTime: PrayerTimeService.formatTime(time),
      isNext: isNext,
      notificationEnabled: _controller.isNotificationEnabled(label),
      icon: _controller.getPrayerIcon(label),
      onTap: () => _showNotificationSettings(label),
    );
  }

  /// Show notification settings
  void _showNotificationSettings(String prayerName) {
    final prayer = _controller.getPrayerFromName(prayerName);
    if (prayer == null) return;

    NotificationSettingsSheet.show(
      context: context,
      prayerName: prayerName,
      prayer: prayer,
      isEnabled: _controller.isNotificationEnabled(prayerName),
      icon: _controller.getPrayerIcon(prayerName),
      onToggle: (value) {
        _controller.togglePrayerNotification(prayer, value);
      },
    );
  }

  /// Format next prayer time
  String _formatNextPrayerTime(PrayerTimes pt, Prayer? prayer) {
    if (prayer == null) return '--:--';
    final time = pt.timeForPrayer(prayer);
    if (time == null) return '--:--';
    return PrayerTimeService.formatTime(time);
  }

  // ==================== UI BUILDERS ====================

  /// Build background with Islamic patterns
  Widget _buildBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 480,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: PrayerTimeConstants.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Geometric Pattern
            CustomPaint(
              painter: IslamicPatternPainter(),
              size: const Size(double.infinity, 480),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Star Pattern
            CustomPaint(
              painter: StarPatternPainter(),
              size: const Size(double.infinity, 480),
            ),

            // Bottom fade
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      PrayerTimeConstants.background.withOpacity(0.3),
                      PrayerTimeConstants.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: PrayerTimeConstants.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  /// Build error screen
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: PrayerTimeConstants.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text(
            'Terjadi kesalahan',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  /// Build no data screen
  Widget _buildNoDataScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: PrayerTimeConstants.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text(
            'Data belum tersedia',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // ==================== DEBUG MENU ====================

  /// Show debug menu for testing
  void _showDebugMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PrayerTimeConstants.radiusXXLarge),
          ),
        ),
        padding: const EdgeInsets.all(PrayerTimeConstants.spacingXXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔧 Debug Menu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: PrayerTimeConstants.spacingXLarge),
            ListTile(
              leading: const Icon(Icons.volume_up, color: Colors.green),
              title: const Text('Test Instant Notification'),
              onTap: () async {
                await QuickNotificationTest.testInstant(context);
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer, color: Colors.blue),
              title: const Text('Test Schedule 30 Detik'),
              onTap: () async {
                await QuickNotificationTest.scheduleIn30Seconds(context);
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.orange),
              title: const Text('Cek Pending Notifications'),
              onTap: () async {
                await QuickNotificationTest.checkPending(context);
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.purple),
              title: const Text('Re-schedule Prayer Times'),
              onTap: () async {
                await _controller.reScheduleNotifications();
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Notifications re-scheduled'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: PrayerTimeConstants.spacingLarge),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }
}