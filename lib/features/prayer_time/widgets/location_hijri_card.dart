import 'package:flutter/material.dart';
import '../constants/prayer_time_constants.dart';

/// 📍 Location and Hijri Date Card
/// Displays user location and Hijri calendar date
class LocationHijriCard extends StatelessWidget {
  final String? city;
  final String? country;
  final String? hijriDate;

  const LocationHijriCard({
    super.key,
    this.city,
    this.country,
    this.hijriDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PrayerTimeConstants.spacingXLarge),
      decoration: BoxDecoration(
        gradient: PrayerTimeConstants.cardGradient(opacity: 0.25),
        borderRadius: BorderRadius.circular(PrayerTimeConstants.radiusXLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: PrayerTimeConstants.elevatedShadow,
      ),
      child: Column(
        children: [
          // Location Section
          _buildLocationRow(),

          // Divider
          if (hijriDate != null) ...[
            const SizedBox(height: PrayerTimeConstants.spacingLarge),
            _buildDivider(),
            const SizedBox(height: PrayerTimeConstants.spacingLarge),
            _buildHijriRow(),
          ],
        ],
      ),
    );
  }

  /// Location Row
  Widget _buildLocationRow() {
    return Row(
      children: [
        // Location Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: PrayerTimeConstants.iconContainerDecoration(
            isActive: true,
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: PrayerTimeConstants.iconLarge,
          ),
        ),
        const SizedBox(width: PrayerTimeConstants.spacingLarge),

        // Location Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lokasi Anda',
                style: PrayerTimeConstants.cardSubtitle.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: PrayerTimeConstants.spacingXSmall),
              Text(
                _formatLocation(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PrayerTimeConstants.cardTitle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Hijri Date Row
  Widget _buildHijriRow() {
    return Row(
      children: [
        // Calendar Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: PrayerTimeConstants.iconContainerDecoration(
            isActive: true,
          ),
          child: const Icon(
            Icons.calendar_today_rounded,
            color: Colors.white,
            size: PrayerTimeConstants.iconLarge,
          ),
        ),
        const SizedBox(width: PrayerTimeConstants.spacingLarge),

        // Hijri Date Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanggal Hijriah',
                style: PrayerTimeConstants.cardSubtitle.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: PrayerTimeConstants.spacingXSmall),
              Text(
                hijriDate ?? '-',
                style: PrayerTimeConstants.cardTitle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Gradient Divider
  Widget _buildDivider() {
    return Container(
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
    );
  }

  /// Format location string
  String _formatLocation() {
    final cityText = city ?? 'Memuat';
    final hasCountry = country != null && country!.isNotEmpty;
    return hasCountry ? '$cityText, $country' : cityText;
  }
}
