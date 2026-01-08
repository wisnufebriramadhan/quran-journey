import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';

import '../prayer_time_provider.dart';
import '../data/prayer_time_service.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {
  static const double _topCardHeight = 180;

  @override
  void initState() {
    super.initState();
    context.read<PrayerTimeProvider>().loadPrayerTimes();
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();

    if (provider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return const Scaffold(
        body: Center(child: Text('Terjadi kesalahan')),
      );
    }

    final pt = provider.prayerTimes;
    final next = provider.nextPrayer;
    final hijri = provider.hijriDate;

    if (pt == null) {
      return const Scaffold(
        body: Center(child: Text('Data belum tersedia')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waktu Sholat'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// =========================
            /// HIJRI DATE
            /// =========================
            if (hijri != null) ...[
              Center(
                child: Text(
                  hijri,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            /// =========================
            /// TOP CARDS
            /// =========================
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: _topCardHeight,
                    child: _locationCard(provider),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: _topCardHeight,
                    child: _nextPrayerCard(
                      title: 'Akan Datang',
                      name: next?.name,
                      time: _formatNextPrayerTime(pt, next),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// =========================
            /// LIST TITLE
            /// =========================
            const Text(
              'Jadwal Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _item('Subuh', pt.fajr),
            _item('Dzuhur', pt.dhuhr),
            _item('Ashar', pt.asr),
            _item('Maghrib', pt.maghrib),
            _item('Isya', pt.isha),
          ],
        ),
      ),
    );
  }

  // =========================
  // LOCATION CARD
  // =========================
  Widget _locationCard(PrayerTimeProvider provider) {
    final city = provider.city ?? 'Memuat lokasi';
    final country = provider.country ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF4F1EC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lokasi',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$city${country.isNotEmpty ? ', $country' : ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Digunakan untuk menentukan waktu sholat',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // =========================
  // NEXT PRAYER CARD
  // =========================
  Widget _nextPrayerCard({
    required String title,
    required String? name,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A7D44), Color(0xFF6FBF73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(
            (name ?? '-').toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Text(
            'Persiapkan diri untuk ibadah',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // =========================
  // LIST ITEM
  // =========================
  Widget _item(String label, DateTime time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 15)),
          ),
          Text(
            PrayerTimeService.formatTime(time),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
