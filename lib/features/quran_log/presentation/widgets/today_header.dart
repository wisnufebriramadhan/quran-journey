import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  final bool isToday;
  final int count;

  const TodayHeader({
    super.key,
    required this.isToday,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isToday ? 'Hari Ini' : 'Riwayat Bacaan',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count catatan bacaan',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
