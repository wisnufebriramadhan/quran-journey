import 'package:flutter/material.dart';
import 'package:quran_tracker/features/quran_log/data/surah.dart';
import '../../../core/models/surah.dart';

class SurahDropdown extends StatelessWidget {
  final Surah? value;
  final ValueChanged<Surah?> onChanged;

  const SurahDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Surah>(
      value: value,
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
      onChanged: onChanged,
    );
  }
}
