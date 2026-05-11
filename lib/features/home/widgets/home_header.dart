import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/auth/auth_provider.dart';
import 'package:quran_tracker/features/extentions.dart';
import 'package:quran_tracker/features/home/providers/home_provider.dart';
import 'package:quran_tracker/features/prayer_time/data/prayer_time_provider.dart';
import 'murattal_player.dart';

class HomeHeader extends StatelessWidget {
  final HomeProvider provider;

  const HomeHeader({
    required this.provider,
    super.key,
  });

  String _formatDuration(Duration d) {
    if (d.isNegative) return 'Sekarang';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '$h j $m mnt' : '$m menit';
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  bool _isFriday() => DateTime.now().weekday == DateTime.friday;

  @override
  Widget build(BuildContext context) {
    final days = provider.remaining.inDays;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 24),
          _buildInfoCard(days),
          const SizedBox(height: 16),
          const MurattalPlayerWidget(),
        ],
      ),
    );
  }

  (String greeting, IconData icon, Color color) _getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (now.weekday == DateTime.friday) {
      return (
        'Jumat Berkah',
        Icons.mosque_rounded,
        const Color(0xFF4CAF50)
      );
    }

    if (hour >= 5 && hour < 11) {
      return ('Selamat Pagi', Icons.wb_sunny_rounded, const Color(0xFFFFB74D));
    } else if (hour >= 11 && hour < 15) {
      return ('Selamat Siang', Icons.wb_sunny_rounded, const Color(0xFFFFA726));
    } else if (hour >= 15 && hour < 18) {
      return ('Selamat Sore', Icons.wb_twilight_rounded, const Color(0xFFEF5350));
    } else {
      return ('Selamat Malam', Icons.nights_stay_rounded, const Color(0xFF42A5F5));
    }
  }

  Widget _buildGreeting() {
    final (greeting, icon, color) = _getTimeBasedGreeting();

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.userName ?? '';
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalamualaikum${name.isNotEmpty ? ', $name' : ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(int days) {
    final isFri = _isFriday();
    final accentColor = isFri ? const Color(0xFF81C784) : Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFri
              ? [
                  const Color(0xFF4CAF50).withOpacity(0.3),
                  const Color(0xFF2E7D32).withOpacity(0.2),
                ]
              : [
                  Colors.white.withOpacity(0.22),
                  Colors.white.withOpacity(0.12),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildHijriSection(days, isFri),
            ),
            Consumer<PrayerTimeProvider>(
              builder: (context, prayer, _) {
                if (prayer.nextPrayerName == null) return const SizedBox.shrink();
                return _buildPrayerSection(prayer, isFri);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHijriSection(int days, bool isFri) {
    final textColor = isFri ? const Color(0xFFE8F5E9) : Colors.white;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isFri ? const Color(0xFF81C784) : Colors.white).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isFri ? Icons.auto_awesome_rounded : Icons.calendar_today_rounded,
            color: textColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${getDayNameIndo(DateTime.now())}, ${getHijriToday()}',
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: isFri ? Colors.yellow.shade200 : Colors.amber.shade300,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$days hari menuju Ramadhan',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildPrayerSection(PrayerTimeProvider prayer, bool isFri) {
    String prayerName = prayer.nextPrayerName ?? '';
    if (isFri && prayerName == 'Dzuhur') prayerName = 'Sholat Jumat';
    
    final textColor = isFri ? const Color(0xFFE8F5E9) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: (isFri ? const Color(0xFF81C784) : Colors.white).withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isFri ? Icons.volunteer_activism_rounded : Icons.notifications_active_rounded,
                color: isFri ? const Color(0xFFC8E6C9) : Colors.amber.shade100,
                size: 18,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selanjutnya: $prayerName',
                    style: TextStyle(
                      color: textColor.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDuration(prayer.remainingToNextPrayer),
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isFri ? Colors.white : Colors.amber.shade400).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatTime(prayer.nextPrayerTime!),
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
