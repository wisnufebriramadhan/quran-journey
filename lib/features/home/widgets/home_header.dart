import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/extentions.dart';
import 'package:quran_tracker/features/home/providers/home_provider.dart';
import 'package:quran_tracker/features/prayer_time/prayer_time_provider.dart';
import 'murattal_player.dart';

class HomeHeader extends StatelessWidget {
  final HomeProvider provider;

  const HomeHeader({
    required this.provider,
    super.key,
  });

  String formatDuration(Duration d) {
    if (d.isNegative) return 'Sekarang';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '$h jam $m menit' : '$m menit';
  }

  String formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final days = provider.remaining.inDays;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 28),
          _buildInfoCard(days),
          const SizedBox(height: 16),
          const MurattalPlayerWidget(),
        ],
      ),
    );
  }

  (String greeting, IconData icon, Color color) _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Pagi: 05:00 - 11:59
      return (
        'Pagi yang indah',
        Icons.wb_sunny_rounded,
        const Color(0xFFFFB74D)
      );
    } else if (hour >= 12 && hour < 17) {
      // Siang: 12:00 - 16:59
      return (
        'Siang yang cerah',
        Icons.wb_sunny_rounded,
        const Color(0xFFFFA726)
      );
    } else if (hour >= 17 && hour < 19) {
      // Sore: 17:00 - 18:59
      return (
        'Sore yang menyenangkan',
        Icons.wb_twilight_rounded,
        const Color(0xFFEF5350)
      );
    } else {
      // Malam: 19:00 - 04:59
      return (
        'Malam yang tenang',
        Icons.nights_stay_rounded,
        const Color(0xFF42A5F5)
      );
    }
  }

  Widget _buildGreeting() {
    final (greeting, icon, color) = _getTimeBasedGreeting();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamualaikum',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Quran Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(int days) {
    return Container(
      width: double.infinity,
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
        borderRadius: BorderRadius.circular(28),
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
          _buildHijriSection(days),
          Consumer<PrayerTimeProvider>(
            builder: (context, prayer, _) {
              if (prayer.nextPrayerName == null ||
                  prayer.nextPrayerTime == null) {
                return const SizedBox.shrink();
              }
              return _buildPrayerSection(prayer);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHijriSection(int days) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hari ini (Hijriah)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                getHijriToday(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Colors.amber.shade300,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$days hari menuju Ramadhan',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerSection(PrayerTimeProvider prayer) {
    return Column(
      children: [
        const SizedBox(height: 20),
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
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade300.withOpacity(0.4),
                    Colors.amber.shade400.withOpacity(0.3),
                  ],
                ),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: Colors.amber.shade100,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sholat Berikutnya',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${prayer.nextPrayerName} • ${formatTime(prayer.nextPrayerTime!)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDuration(prayer.remainingToNextPrayer),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
