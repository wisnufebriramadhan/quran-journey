import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../constants/prayer_time_constants.dart';

/// 🔔 Notification Settings Bottom Sheet
/// Modal for managing prayer notification settings
class NotificationSettingsSheet extends StatelessWidget {
  final String prayerName;
  final Prayer prayer;
  final bool isEnabled;
  final IconData icon;
  final Function(bool) onToggle;

  const NotificationSettingsSheet({
    super.key,
    required this.prayerName,
    required this.prayer,
    required this.isEnabled,
    required this.icon,
    required this.onToggle,
  });

  /// Show bottom sheet
  static void show({
    required BuildContext context,
    required String prayerName,
    required Prayer prayer,
    required bool isEnabled,
    required IconData icon,
    required Function(bool) onToggle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationSettingsSheet(
        prayerName: prayerName,
        prayer: prayer,
        isEnabled: isEnabled,
        icon: icon,
        onToggle: onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PrayerTimeConstants.radiusXXLarge),
        ),
      ),
      padding: const EdgeInsets.all(PrayerTimeConstants.spacingXXLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: PrayerTimeConstants.spacingXXLarge),

          // Toggle Switch
          _buildToggleSection(context),
          const SizedBox(height: PrayerTimeConstants.spacingLarge),

          // Close Button
          _buildCloseButton(context),

          // Bottom Padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Build header with icon and title
  Widget _buildHeader() {
    return Row(
      children: [
        // Prayer Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            gradient: PrayerTimeConstants.primaryGradient,
            borderRadius: BorderRadius.all(
              Radius.circular(PrayerTimeConstants.radiusMedium),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: PrayerTimeConstants.iconLarge,
          ),
        ),
        const SizedBox(width: PrayerTimeConstants.spacingLarge),

        // Title and Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifikasi $prayerName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PrayerTimeConstants.textDark,
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
    );
  }

  /// Build toggle switch section
  Widget _buildToggleSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PrayerTimeConstants.background,
        borderRadius: BorderRadius.circular(PrayerTimeConstants.radiusLarge),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PrayerTimeConstants.spacingXLarge,
          vertical: PrayerTimeConstants.spacingSmall,
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
        activeColor: PrayerTimeConstants.primaryBrown,
        onChanged: (value) {
          onToggle(value);
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Build close button
  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: PrayerTimeConstants.spacingLarge,
          ),
        ),
        child: const Text(
          'Tutup',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
