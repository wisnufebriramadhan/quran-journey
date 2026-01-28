import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/quran_log_provider.dart';
import 'add_log_sheet.dart';

class AddLogButton extends StatelessWidget {
  const AddLogButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranLogProvider>();
    final isDisabled = provider.hasLoggedToday;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(
            isDisabled
                ? 'Bacaan Hari Ini Sudah Dicatat'
                : 'Tambah Bacaan Hari Ini',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDisabled ? Colors.grey.shade300 : const Color(0xFF5D4037),
            foregroundColor: isDisabled ? Colors.grey.shade700 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: isDisabled
              ? null
              : () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const AddLogSheet(),
                  );
                },
        ),
      ),
    );
  }
}
