import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../quran_log_provider.dart';

class QuranLogCalendar extends StatefulWidget {
  final Function(DateTime, List)? onDateSelected;

  const QuranLogCalendar({super.key, this.onDateSelected});

  @override
  State<QuranLogCalendar> createState() => _QuranLogCalendarState();
}

class _QuranLogCalendarState extends State<QuranLogCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranLogProvider>();
    final events = provider.logsByDate;

    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) =>
          _selectedDay != null && isSameDay(day, _selectedDay),
      eventLoader: (day) {
        final key = DateTime(day.year, day.month, day.day);
        return events[key] ?? [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });

        final key =
            DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
        widget.onDateSelected?.call(selectedDay, events[key] ?? []);
      },
      calendarStyle: CalendarStyle(
        markerDecoration: const BoxDecoration(
          color: Colors.brown,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.brown,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
