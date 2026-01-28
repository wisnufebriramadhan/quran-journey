import 'package:flutter/material.dart';
import '../constants/prayer_time_constants.dart';

/// 📱 Prayer Header Section
/// Displays back button and page title
class PrayerHeaderSection extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onDebugLongPress;

  const PrayerHeaderSection({
    super.key,
    this.onBackPressed,
    this.onDebugLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back Button
        GestureDetector(
          onTap: onBackPressed ?? () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(
                PrayerTimeConstants.radiusLarge,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: PrayerTimeConstants.iconLarge,
            ),
          ),
        ),
        const SizedBox(width: PrayerTimeConstants.spacingLarge),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waktu Sholat',
                style: PrayerTimeConstants.headerSubtitle.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: PrayerTimeConstants.spacingXSmall),
              GestureDetector(
                onLongPress: onDebugLongPress,
                child: const Text(
                  'Jadwal Hari Ini',
                  style: PrayerTimeConstants.headerTitle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
