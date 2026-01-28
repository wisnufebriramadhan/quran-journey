import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 24),
      child: Text(
        'Tidak ada bacaan di tanggal ini',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
