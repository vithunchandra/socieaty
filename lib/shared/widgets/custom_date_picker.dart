import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final int daysRange;

  const CustomDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.daysRange = 14,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selectedDate;
  final ScrollController _datePickerScrollController = ScrollController();
  List<DateTime> _dates = [];
  final double _dayWidth = 52.0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _generateDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _generateDates() {
    _dates = [];
    final now = DateTime.now();
    // Generate 14 days with current day in the middle (7 days before, current day, 6 days after)
    final int halfRange = widget.daysRange ~/ 2;
    final int remainingDays = widget.daysRange - halfRange - 1;

    for (int i = -halfRange; i <= remainingDays; i++) {
      _dates.add(DateTime(now.year, now.month, now.day + i));
    }
  }

  void _scrollToSelectedDate() {
    if (!_datePickerScrollController.hasClients) return;

    final selectedIndex = _dates.indexWhere((date) =>
        DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate));

    if (selectedIndex != -1) {
      final screenWidth = MediaQuery.of(context).size.width;
      // Account for the item width, horizontal padding, and margins
      final horizontalPadding = 16; // ListView's horizontal padding
      final offset =
          (selectedIndex * (_dayWidth)) + horizontalPadding - (screenWidth / 2) + (_dayWidth / 2);

      _datePickerScrollController.animateTo(
        offset > 0 ? offset : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _datePickerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppPallete.neutralColor.shade800,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _datePickerScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              itemExtent: _dayWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final date = _dates[index];
                final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDate);
                final isToday = DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    widget.onDateSelected(date);
                    _scrollToSelectedDate();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppPallete.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppPallete.neutralColor.shade200.withAlpha(40),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? AppPallete.primaryColor
                            : isToday
                                ? AppPallete.primaryColor.withAlpha(70)
                                : AppPallete.neutralColor.shade100,
                        width: isToday && !isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(date),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppPallete.neutralColor.shade800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('E').format(date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected ? Colors.white : AppPallete.neutralColor.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
