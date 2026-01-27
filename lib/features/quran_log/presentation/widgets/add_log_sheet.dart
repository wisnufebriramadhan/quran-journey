import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/quran_log/data/surah.dart';

import '../../quran_log_provider.dart';
import '../../../../core/helpers/date_helper.dart';
import '../../../../core/models/surah.dart';

class AddLogSheet extends StatefulWidget {
  const AddLogSheet({super.key});

  @override
  State<AddLogSheet> createState() => _AddLogSheetState();
}

class _AddLogSheetState extends State<AddLogSheet> {
  Surah? selectedSurah;

  final ayatFromController = TextEditingController();
  final ayatToController = TextEditingController();
  final durationController = TextEditingController();

  @override
  void dispose() {
    ayatFromController.dispose();
    ayatToController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<QuranLogProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================
          // TITLE
          // ======================
          const Text(
            'Catat Bacaan Hari Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // ======================
          // SURAH DROPDOWN
          // ======================
          DropdownButtonFormField<Surah>(
            value: selectedSurah,
            decoration: const InputDecoration(
              labelText: 'Surah',
              border: OutlineInputBorder(),
            ),
            items: surahList.map((surah) {
              return DropdownMenuItem(
                value: surah,
                child: Text('${surah.number}. ${surah.name}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSurah = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // ======================
          // AYAT
          // ======================
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ayatFromController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ayat Dari',
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ======================
          // DURATION
          // ======================
          TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Durasi (menit)',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // ======================
          // SUBMIT BUTTON
          // ======================
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: selectedSurah == null
                  ? null
                  : () async {
                      await provider.addLog({
                        'date': DateHelper.todayString(),
                        'surah': selectedSurah!.name,
                        'ayat_from': int.parse(ayatFromController.text),
                        'ayat_to': int.parse(ayatToController.text),
                        'duration': durationController.text.isEmpty
                            ? null
                            : int.parse(durationController.text),
                      });

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
              child: const Text('Simpan Bacaan'),
            ),
          ),
        ],
      ),
    );
  }
}
