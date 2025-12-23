import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../quran_log_provider.dart';
import 'widgets/calendar_widget.dart';
import '../../../core/helpers/date_helper.dart';

class QuranLogPage extends StatefulWidget {
  const QuranLogPage({super.key});

  @override
  State<QuranLogPage> createState() => _QuranLogPageState();
}

class _QuranLogPageState extends State<QuranLogPage> {
  final surahController = TextEditingController();
  final ayatFromController = TextEditingController();
  final ayatToController = TextEditingController();
  final durationController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<QuranLogProvider>().fetchLogs();
  }

  @override
  void dispose() {
    surahController.dispose();
    ayatFromController.dispose();
    ayatToController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranLogProvider>();

    final logsByDate = provider.logsByDate;
    final selectedLogs = logsByDate[selectedDate] ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Al-Qur’an'),
      ),
      body: Builder(
        builder: (_) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ======================
                /// KALENDER
                /// ======================
                QuranLogCalendar(
                  onDateSelected: (date, _) {
                    setState(() => selectedDate = date);
                  },
                ),

                const SizedBox(height: 20),

                /// ======================
                /// FORM (HANYA HARI INI)
                /// ======================
                if (DateHelper.isToday(selectedDate)) ...[
                  const Text(
                    'Input Bacaan Hari Ini',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: surahController,
                    decoration: const InputDecoration(
                      labelText: 'Surah',
                      hintText: 'Contoh: Al-Ikhlas',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ayatFromController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Ayat Dari',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: ayatToController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Ayat Sampai',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Durasi (menit)',
                      hintText: 'Opsional',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final surah = surahController.text.trim();
                        final from = int.tryParse(ayatFromController.text);
                        final to = int.tryParse(ayatToController.text);
                        final duration = int.tryParse(durationController.text);

                        if (surah.isEmpty || from == null || to == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mohon lengkapi data bacaan'),
                            ),
                          );
                          return;
                        }

                        await provider.addLog({
                          'date': DateHelper.todayString(),
                          'surah': surah,
                          'ayat_from': from,
                          'ayat_to': to,
                          'duration': duration,
                        });

                        surahController.clear();
                        ayatFromController.clear();
                        ayatToController.clear();
                        durationController.clear();
                      },
                      child: const Text('Simpan Bacaan Hari Ini'),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Riwayat Bacaan (Read Only)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],

                const Divider(height: 32),

                /// ======================
                /// DETAIL BACAAAN
                /// ======================
                if (selectedLogs.isNotEmpty) ...[
                  const Text(
                    'Detail Bacaan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...selectedLogs.map((log) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.surah,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ayat ${log.ayatFrom} – ${log.ayatTo}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          if (log.duration != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Durasi ${log.duration} menit',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  const Text(
                    'Tidak ada bacaan di tanggal ini',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
