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
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ======================
          // METODE WAKTU SHOLAT
          // ======================
          const Text(
            'Metode Waktu Sholat',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          RadioListTile<PrayerMethodType>(
            title: const Text('Kemenag RI'),
            value: PrayerMethodType.kemenag,
            groupValue: settings.prayerMethod,
            onChanged: (PrayerMethodType? v) {
              if (v != null) {
                context.read<SettingsProvider>().setPrayerMethod(v);
              }
            },
          ),

          RadioListTile<PrayerMethodType>(
            title: const Text('Muslim World League'),
            value: PrayerMethodType.mwl,
            groupValue: settings.prayerMethod,
            onChanged: (PrayerMethodType? v) {
              if (v != null) {
                context.read<SettingsProvider>().setPrayerMethod(v);
              }
            },
          ),

          const Divider(height: 32),

          // ======================
          // METODE HIJRIAH
          // ======================
          const Text(
            'Metode Tanggal Hijriah',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          RadioListTile<HijriMethodType>(
            title: const Text('Kuwait'),
            value: HijriMethodType.kuwait,
            groupValue: settings.hijriMethod,
            onChanged: (HijriMethodType? v) {
              if (v != null) {
                context.read<SettingsProvider>().setHijriMethod(v);
              }
            },
          ),

          RadioListTile<HijriMethodType>(
            title: const Text('Ummul Qura'),
            value: HijriMethodType.ummulQura,
            groupValue: settings.hijriMethod,
            onChanged: (HijriMethodType? v) {
              if (v != null) {
                context.read<SettingsProvider>().setHijriMethod(v);
              }
            },
          ),

          const SizedBox(height: 16),

          // ======================
          // OFFSET HIJRIAH
          // ======================
          const Text('Penyesuaian Hari Hijriah'),

          Slider(
            min: -2,
            max: 2,
            divisions: 4,
            label: '${settings.hijriOffset} hari',
            value: settings.hijriOffset.toDouble(),
            onChanged: (v) {
              context
                  .read<SettingsProvider>()
                  .setHijriOffset(v.toInt());
            },
          ),
        ],
      ),
    );
  }
}
