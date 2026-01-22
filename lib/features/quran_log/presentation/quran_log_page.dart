import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/quran_log/presentation/widgets/calendar_widget.dart';
import '../quran_log_provider.dart';
import 'widgets/today_header.dart';
import 'widgets/add_log_button.dart';
import 'widgets/log_item.dart';
import 'widgets/empty_state.dart';
import 'widgets/add_log_sheet.dart';
import '../../../core/helpers/date_helper.dart';

class QuranLogPage extends StatefulWidget {
  const QuranLogPage({super.key});

  @override
  State<QuranLogPage> createState() => _QuranLogPageState();
}

class _QuranLogPageState extends State<QuranLogPage> {
  DateTime selectedDate = DateTime.now();
  List selectedLogs = [];

  @override
  void initState() {
    super.initState();
    context.read<QuranLogProvider>().fetchLogs();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddLogSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranLogProvider>();

    if (provider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(child: Text(provider.error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Al-Qur’an')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TodayHeader(
              isToday: DateHelper.isToday(selectedDate),
              count: selectedLogs.length,
            ),
            if (DateHelper.isToday(selectedDate)) const AddLogButton(),
            const SizedBox(height: 16),
            QuranLogCalendar(
              onDateSelected: (date, logs) {
                setState(() {
                  selectedDate = date;
                  selectedLogs = logs;
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedLogs.isEmpty)
              const EmptyState()
            else
              ...selectedLogs.map((log) => LogItem(log: log)),
          ],
        ),
      ),
    );
  }
}
