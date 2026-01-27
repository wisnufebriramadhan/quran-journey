import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';

import '../prayer_time_provider.dart';
import '../data/prayer_time_service.dart';
import '../data/notification_service.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();

  // Notification settings
  bool _fajrEnabled = true;
  bool _dhuhrEnabled = true;
  bool _asrEnabled = true;
  bool _maghribEnabled = true;
  bool _ishaEnabled = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerTimeProvider>().loadPrayerTimes();
      _loadNotificationSettings();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load notification settings
  Future<void> _loadNotificationSettings() async {
    _fajrEnabled =
        await _notificationService.getPrayerNotificationEnabled(Prayer.fajr);
    _dhuhrEnabled =
        await _notificationService.getPrayerNotificationEnabled(Prayer.dhuhr);
    _asrEnabled =
        await _notificationService.getPrayerNotificationEnabled(Prayer.asr);
    _maghribEnabled =
        await _notificationService.getPrayerNotificationEnabled(Prayer.maghrib);
    _ishaEnabled =
        await _notificationService.getPrayerNotificationEnabled(Prayer.isha);

    if (mounted) {
      setState(() {});
    }
  }

  /// Toggle notification for specific prayer
  Future<void> _togglePrayer(Prayer prayer, bool value) async {
    await _notificationService.setPrayerNotificationEnabled(prayer, value);

    if (mounted) {
      setState(() {
        switch (prayer) {
          case Prayer.fajr:
            _fajrEnabled = value;
            break;
          case Prayer.dhuhr:
            _dhuhrEnabled = value;
            break;
          case Prayer.asr:
            _asrEnabled = value;
            break;
          case Prayer.maghrib:
            _maghribEnabled = value;
            break;
          case Prayer.isha:
            _ishaEnabled = value;
            break;
          default:
            break;
        }
      });
    }
  }

  /// Get notification enabled status for prayer
  bool _isNotificationEnabled(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'subuh':
        return _fajrEnabled;
      case 'dzuhur':
        return _dhuhrEnabled;
      case 'ashar':
        return _asrEnabled;
      case 'maghrib':
        return _maghribEnabled;
      case 'isya':
        return _ishaEnabled;
      default:
        return false;
    }
  }

  /// Get Prayer enum from name
  Prayer? _getPrayerFromName(String prayerName) {
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

  /// Show notification settings bottom sheet
  void _showNotificationSettings(String prayerName) {
    final prayer = _getPrayerFromName(prayerName);
    if (prayer == null) return;

    final isEnabled = _isNotificationEnabled(prayerName);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPrayerIcon(prayerName),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi $prayerName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Text(
                        isEnabled ? 'Dengan suara' : 'Tanpa suara (silent)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: const Text(
                  'Aktifkan Notifikasi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  isEnabled
                      ? 'Notifikasi akan berbunyi saat waktu sholat tiba'
                      : 'Notifikasi tanpa suara',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                value: isEnabled,
                activeColor: const Color(0xFF6D4C41),
                onChanged: (value) {
                  _togglePrayer(prayer, value);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// SAFE FORMAT NEXT PRAYER
  /// =========================
  String _formatNextPrayerTime(
    PrayerTimes pt,
    Prayer? prayer,
  ) {
    if (prayer == null) return '--:--';

    final time = pt.timeForPrayer(prayer);
    if (time == null) return '--:--';

    return PrayerTimeService.formatTime(time);
  }

  /// =========================
  /// GET PRAYER ICON
  /// =========================
  IconData _getPrayerIcon(String prayerName) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();

    if (provider.loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3E2723),
                Color(0xFF4A3428),
                Color(0xFF5D4037),
                Color(0xFF6D4C41),
              ],
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

    if (provider.error != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3E2723),
                Color(0xFF4A3428),
                Color(0xFF5D4037),
                Color(0xFF6D4C41),
              ],
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

    final pt = provider.prayerTimes;
    final next = provider.nextPrayer;
    final hijri = provider.hijriDate;

    if (pt == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3E2723),
                Color(0xFF4A3428),
                Color(0xFF5D4037),
                Color(0xFF6D4C41),
              ],
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Enhanced Background with Islamic Pattern
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 480,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF3E2723),
                        Color(0xFF4A3428),
                        Color(0xFF5D4037),
                        Color(0xFF6D4C41),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Geometric Pattern Layer
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
                      // Bottom gradient fade
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
                                const Color(0xFFF8F9FA).withOpacity(0.3),
                                const Color(0xFFF8F9FA),
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
              ),

              SingleChildScrollView(
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
                      /// =========================
                      /// HEADER SECTION
                      /// =========================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Waktu Sholat',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Jadwal Hari Ini',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            /// =========================
                            /// LOCATION & HIJRI CARD
                            /// =========================
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.25),
                                    Colors.white.withOpacity(0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.2),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Lokasi Anda',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white
                                                    .withOpacity(0.85),
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${provider.city ?? 'Memuat'}${provider.country != null && provider.country!.isNotEmpty ? ', ${provider.country}' : ''}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (hijri != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 1.5,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white.withOpacity(0.4),
                                            Colors.white.withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.2),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Tanggal Hijriah',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white
                                                      .withOpacity(0.85),
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                hijri,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// =========================
                            /// NEXT PRAYER CARD
                            /// =========================
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.25),
                                    Colors.white.withOpacity(0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                                  255, 255, 255, 255)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.access_time,
                                          color: Colors.amber.shade200,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Sholat Berikutnya',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.85),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    (next?.name ?? '-').toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatNextPrayerTime(pt, next),
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'WIB',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.notifications_active,
                                          size: 16,
                                          color: Colors.amber.shade200,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Persiapkan diri untuk ibadah',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF3E2723),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// =========================
                      /// PRAYER TIMES LIST
                      /// =========================
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jadwal Lengkap',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _modernPrayerItem(
                                'Subuh', pt.fajr, next?.name == 'Fajr'),
                            _modernPrayerItem(
                                'Dzuhur', pt.dhuhr, next?.name == 'Dhuhr'),
                            _modernPrayerItem(
                                'Ashar', pt.asr, next?.name == 'Asr'),
                            _modernPrayerItem(
                                'Maghrib', pt.maghrib, next?.name == 'Maghrib'),
                            _modernPrayerItem(
                                'Isya', pt.isha, next?.name == 'Isha'),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// MODERN PRAYER ITEM
  /// =========================
  Widget _modernPrayerItem(String label, DateTime time, bool isNext) {
    final notifEnabled = _isNotificationEnabled(label);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: isNext
                ? const Color(0xFF6D4C41).withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showNotificationSettings(label),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isNext
                  ? const LinearGradient(
                      colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isNext
                        ? LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.2),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFF6D4C41).withOpacity(0.15),
                              const Color(0xFF5D4037).withOpacity(0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPrayerIcon(label),
                    color: isNext ? Colors.white : const Color(0xFF6D4C41),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isNext ? Colors.white : const Color(0xFF3E2723),
                        ),
                      ),
                      if (!notifEnabled)
                        Text(
                          'Notifikasi: Silent',
                          style: TextStyle(
                            fontSize: 11,
                            color: isNext
                                ? Colors.white.withOpacity(0.7)
                                : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  PrayerTimeService.formatTime(time),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isNext ? Colors.white : const Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  notifEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  size: 20,
                  color: isNext
                      ? Colors.white.withOpacity(0.8)
                      : (notifEnabled
                          ? const Color(0xFF6D4C41)
                          : Colors.grey[400]),
                ),
                if (isNext) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= ISLAMIC PATTERN PAINTER =================
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const spacing = 80.0;
    const radius1 = 25.0;
    const radius2 = 12.0;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius1, paint);
        canvas.drawCircle(Offset(x, y), radius2, paint);

        final paint2 = Paint()
          ..color = Colors.white.withOpacity(0.02)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawLine(
          Offset(x - radius1, y),
          Offset(x + radius1, y),
          paint2,
        );
        canvas.drawLine(
          Offset(x, y - radius1),
          Offset(x, y + radius1),
          paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ================= STAR PATTERN PAINTER =================
class StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final random = Random(42);

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 2.0 + random.nextDouble() * 3;

      _drawStar(canvas, Offset(x, y), starSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 5;
    const angle = (pi * 2) / points;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? size : size / 2;
      final currentAngle = angle * i - pi / 2;
      final x = center.dx + cos(currentAngle) * r;
      final y = center.dy + sin(currentAngle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
