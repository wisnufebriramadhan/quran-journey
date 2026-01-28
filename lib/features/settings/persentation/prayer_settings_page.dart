import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/settings/data/settings_model.dart';
import 'package:quran_tracker/features/settings/settings_provider.dart';

class PrayerSettingsPage extends StatelessWidget {
  const PrayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Waktu Sholat'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================
          // SECTION: METODE WAKTU SHOLAT
          // ==========================================
          _buildSectionHeader('Metode Perhitungan Waktu Sholat'),
          const SizedBox(height: 8),
          
          _buildMethodCard(
            context,
            title: 'SIHAT Indonesia',
            subtitle: 'Sistem Informasi Hisab Rukyat Indonesia',
            isSelected: settings.prayerMethod == PrayerMethodType.sihat,
            onTap: () {
              context.read<SettingsProvider>().setPrayerMethod(
                PrayerMethodType.sihat,
              );
            },
          ),

          _buildMethodCard(
            context,
            title: 'Kemenag RI',
            subtitle: 'Kementerian Agama Republik Indonesia',
            isSelected: settings.prayerMethod == PrayerMethodType.kemenag,
            onTap: () {
              context.read<SettingsProvider>().setPrayerMethod(
                PrayerMethodType.kemenag,
              );
            },
          ),

          _buildMethodCard(
            context,
            title: 'Muslim World League',
            subtitle: 'Standar internasional untuk perhitungan',
            isSelected: settings.prayerMethod == PrayerMethodType.mwl,
            onTap: () {
              context.read<SettingsProvider>().setPrayerMethod(
                PrayerMethodType.mwl,
              );
            },
          ),

          const SizedBox(height: 24),

          // ==========================================
          // SECTION: PENYESUAIAN WAKTU SHOLAT
          // ==========================================
          _buildSectionHeader('Penyesuaian Waktu (menit)'),
          const SizedBox(height: 8),
          
          _buildInfoCard(
            'Sesuaikan waktu jika ada perbedaan dengan jadwal lokal Anda',
            Icons.info_outline,
          ),
          
          const SizedBox(height: 16),

          _buildOffsetSlider(
            context,
            label: 'Subuh',
            icon: Icons.brightness_2,
            value: settings.fajrOffset,
            onChanged: (v) {
              context.read<SettingsProvider>().setPrayerOffset(fajr: v);
            },
          ),

          _buildOffsetSlider(
            context,
            label: 'Dzuhur',
            icon: Icons.wb_sunny,
            value: settings.dhuhrOffset,
            onChanged: (v) {
              context.read<SettingsProvider>().setPrayerOffset(dhuhr: v);
            },
          ),

          _buildOffsetSlider(
            context,
            label: 'Ashar',
            icon: Icons.wb_sunny_outlined,
            value: settings.asrOffset,
            onChanged: (v) {
              context.read<SettingsProvider>().setPrayerOffset(asr: v);
            },
          ),

          _buildOffsetSlider(
            context,
            label: 'Maghrib',
            icon: Icons.wb_twilight,
            value: settings.maghribOffset,
            onChanged: (v) {
              context.read<SettingsProvider>().setPrayerOffset(maghrib: v);
            },
          ),

          _buildOffsetSlider(
            context,
            label: 'Isya',
            icon: Icons.nightlight_round,
            value: settings.ishaOffset,
            onChanged: (v) {
              context.read<SettingsProvider>().setPrayerOffset(isha: v);
            },
          ),

          const SizedBox(height: 24),

          // ==========================================
          // SECTION: METODE HIJRIAH
          // ==========================================
          _buildSectionHeader('Perhitungan Tanggal Hijriah'),
          const SizedBox(height: 8),

          _buildMethodCard(
            context,
            title: 'Kuwait',
            subtitle: 'Metode Kuwait untuk kalender Hijriah',
            isSelected: settings.hijriMethod == HijriMethodType.kuwait,
            onTap: () {
              context.read<SettingsProvider>().setHijriMethod(
                HijriMethodType.kuwait,
              );
            },
          ),

          _buildMethodCard(
            context,
            title: 'Ummul Qura',
            subtitle: 'Metode Arab Saudi untuk kalender Hijriah',
            isSelected: settings.hijriMethod == HijriMethodType.ummulQura,
            onTap: () {
              context.read<SettingsProvider>().setHijriMethod(
                HijriMethodType.ummulQura,
              );
            },
          ),

          const SizedBox(height: 16),

          // Hijri Offset
          _buildHijriOffsetSlider(context, settings),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffsetSlider(
    BuildContext context, {
    required String label,
    required IconData icon,
    required int value,
    required Function(int) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: value == 0 ? Colors.grey[200] : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value == 0 ? 'Standar' : '${value > 0 ? '+' : ''}$value menit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: value == 0 ? Colors.grey[700] : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              min: -10,
              max: 10,
              divisions: 20,
              value: value.toDouble(),
              onChanged: (v) => onChanged(v.toInt()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHijriOffsetSlider(BuildContext context, SettingsModel settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Penyesuaian Tanggal Hijriah',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: settings.hijriOffset == 0 
                        ? Colors.grey[200] 
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    settings.hijriOffset == 0 
                        ? 'Standar' 
                        : '${settings.hijriOffset > 0 ? '+' : ''}${settings.hijriOffset} hari',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: settings.hijriOffset == 0 
                          ? Colors.grey[700] 
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              min: -2,
              max: 2,
              divisions: 4,
              value: settings.hijriOffset.toDouble(),
              onChanged: (v) {
                context.read<SettingsProvider>().setHijriOffset(v.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }
}