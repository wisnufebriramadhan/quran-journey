import 'package:flutter/material.dart';
import '../constants/prayer_time_constants.dart';

/// ⏰ Next Prayer Card
/// Displays the upcoming prayer time prominently
class NextPrayerCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;

  const NextPrayerCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PrayerTimeConstants.spacingXXLarge),
      decoration: BoxDecoration(
        gradient: PrayerTimeConstants.cardGradient(opacity: 0.25),
        borderRadius: BorderRadius.circular(PrayerTimeConstants.radiusXXLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: PrayerTimeConstants.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: PrayerTimeConstants.spacingXLarge),

          // Prayer Name
          Text(
            prayerName.toUpperCase(),
            style: PrayerTimeConstants.prayerName,
          ),
          const SizedBox(height: PrayerTimeConstants.spacingSmall),

          // Prayer Time
          _buildTimeDisplay(),
          const SizedBox(height: PrayerTimeConstants.spacingLarge),

          // Reminder Badge
          _buildReminderBadge(),
        ],
      ),
    );
  }

  /// Build header with icon and label
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(
              PrayerTimeConstants.radiusMedium,
            ),
          ),
          child: Icon(
            Icons.access_time,
            color: Colors.amber.shade200,
            size: PrayerTimeConstants.iconMedium,
          ),
        ),
        const SizedBox(width: PrayerTimeConstants.spacingMedium),
        Text(
          'Sholat Berikutnya',
          style: PrayerTimeConstants.cardSubtitle.copyWith(
            fontSize: 14,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }

  /// Build large time display
  Widget _buildTimeDisplay() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          prayerTime,
          style: PrayerTimeConstants.timeDisplay,
        ),
        const SizedBox(width: PrayerTimeConstants.spacingSmall),
        Padding(
          padding: const EdgeInsets.only(
            bottom: PrayerTimeConstants.spacingSmall,
          ),
          child: Text(
            'WIB',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  /// Build reminder badge
  Widget _buildReminderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrayerTimeConstants.spacingMedium,
        vertical: PrayerTimeConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(PrayerTimeConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_active,
            size: PrayerTimeConstants.iconSmall,
            color: Colors.amber.shade200,
          ),
          const SizedBox(width: 6),
          const Text(
            'Persiapkan diri untuk ibadah',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
