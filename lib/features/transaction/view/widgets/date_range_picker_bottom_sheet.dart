import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class DateRangePickerBottomSheet extends StatefulWidget {
  const DateRangePickerBottomSheet({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onDateRangeSelected,
  });

  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime startDate, DateTime endDate) onDateRangeSelected;

  @override
  State<DateRangePickerBottomSheet> createState() => _DateRangePickerBottomSheetState();
}

class _DateRangePickerBottomSheetState extends State<DateRangePickerBottomSheet> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Rentang Tanggal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  context,
                  'Mulai',
                  _startDate,
                  (newDate) {
                    if (newDate != null) {
                      setState(() {
                        _startDate = newDate;
                        // Ensure end date is not before start date
                        if (_endDate.isBefore(_startDate)) {
                          _endDate = _startDate;
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  context,
                  'Berakhir',
                  _endDate,
                  (newDate) {
                    if (newDate != null && !newDate.isBefore(_startDate)) {
                      setState(() {
                        _endDate = newDate;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPresetButtons(context),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                widget.onDateRangeSelected(_startDate, _endDate);
                Navigator.pop(context);
              },
              child: const Text(
                'Terapkan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPallete.neutralColor.shade700,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppPallete.primaryColor,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            onDateSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppPallete.neutralColor.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppPallete.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPresetButton(
          '7 Hari Lalu',
          () {
            final now = DateTime.now();
            setState(() {
              _endDate = now;
              _startDate = now.subtract(const Duration(days: 7));
            });
          },
        ),
        _buildPresetButton(
          '14 Hari Lalu',
          () {
            final now = DateTime.now();
            setState(() {
              _endDate = now;
              _startDate = now.subtract(const Duration(days: 14));
            });
          },
        ),
        _buildPresetButton(
          'Bulan ini',
          () {
            final now = DateTime.now();
            setState(() {
              _endDate = now;
              _startDate = DateTime(now.year, now.month, 1);
            });
          },
        ),
        _buildPresetButton(
          'Bulan Lalu',
          () {
            final now = DateTime.now();
            final lastMonth = DateTime(now.year, now.month - 1);
            setState(() {
              _startDate = DateTime(lastMonth.year, lastMonth.month, 1);
              _endDate = DateTime(now.year, now.month, 0);
            });
          },
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppPallete.primaryColor.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppPallete.primaryColor.shade500,
          fontSize: 12,
        ),
      ),
    );
  }
}
