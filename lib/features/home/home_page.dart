import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _MenuCard(
              icon: Icons.menu_book_rounded,
              title: 'Pencatatan Al-Qur’an',
              subtitle: 'Catat bacaan harian dan lihat riwayat',
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.quranLog);
              },
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.mosque_rounded,
              title: 'Waktu Sholat',
              subtitle: 'Jadwal sholat & azan hari ini',
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.prayerTime);
              },
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.settings_rounded,
              title: 'Pengaturan',
              subtitle: 'Waktu sholat & kalender hijriah',
              color: Colors.blueGrey,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.08),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
