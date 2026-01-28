import 'package:flutter/material.dart';
import '../data/quran_log_model.dart';

class LogItem extends StatelessWidget {
  final QuranLog log;

  const LogItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          log.surah,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Ayat ${log.ayatFrom}-${log.ayatTo}'),
        trailing: Text(
          log.duration != null ? '${log.duration} m' : '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
