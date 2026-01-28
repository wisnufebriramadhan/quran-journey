import 'package:flutter/material.dart';
import '../constants/prayer_time_constants.dart';

/// 🕌 Prayer Item Card
/// Individual prayer time item with notification toggle
class PrayerItemCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final bool isNext;
  final bool notificationEnabled;
  final IconData icon;
  final VoidCallback onTap;

  const PrayerItemCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.isNext,
    required this.notificationEnabled,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: PrayerTimeConstants.spacingMedium,
      ),
      decoration: PrayerTimeConstants.cardDecoration(
        isActive: isNext,
        hasBorder: false,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            PrayerTimeConstants.radiusXLarge,
          ),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: isNext
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      PrayerTimeConstants.radiusXLarge,
                    ),
                    gradient: PrayerTimeConstants.primaryGradient,
                  )
                : null,
            child: Row(
              children: [
                // Prayer Icon
                _buildIcon(),
                const SizedBox(width: PrayerTimeConstants.spacingLarge),

                // Prayer Name & Status
                Expanded(
                  child: _buildPrayerInfo(),
                ),

                // Prayer Time
                Text(
                  prayerTime,
                  style: PrayerTimeConstants.prayerItemTime.copyWith(
                    color: isNext ? Colors.white : PrayerTimeConstants.textDark,
                  ),
                ),
                const SizedBox(width: PrayerTimeConstants.spacingMedium),

                // Notification Icon
                _buildNotificationIcon(),

                // Next Badge
                if (isNext) ...[
                  const SizedBox(width: PrayerTimeConstants.spacingSmall),
                  _buildNextBadge(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build prayer icon container
  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: PrayerTimeConstants.iconContainerDecoration(
        isActive: isNext,
      ),
      child: Icon(
        icon,
        color: isNext ? Colors.white : PrayerTimeConstants.primaryBrown,
        size: 22,
      ),
    );
  }

  /// Build prayer name and notification status
  Widget _buildPrayerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prayerName,
          style: PrayerTimeConstants.prayerItemTitle.copyWith(
            color: isNext ? Colors.white : PrayerTimeConstants.textDark,
          ),
        ),
        if (!notificationEnabled)
          Text(
            'Notifikasi: Silent',
            style: TextStyle(
              fontSize: 11,
              color: isNext ? Colors.white.withOpacity(0.7) : Colors.grey[600],
            ),
          ),
      ],
    );
  }

  /// Build notification icon
  Widget _buildNotificationIcon() {
    return Icon(
      notificationEnabled
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
      size: PrayerTimeConstants.iconMedium,
      color: isNext
          ? Colors.white.withOpacity(0.8)
          : (notificationEnabled
              ? PrayerTimeConstants.primaryBrown
              : Colors.grey[400]),
    );
  }

  /// Build next prayer badge
  Widget _buildNextBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrayerTimeConstants.spacingSmall,
        vertical: PrayerTimeConstants.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Next',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: PrayerTimeConstants.textDark,
        ),
      ),
    );
  }
}
