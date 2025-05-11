import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class TransactionFilterBottomSheet extends StatefulWidget {
  final DateTime? rangeStartDate;
  final DateTime? rangeEndDate;
  final TransactionSortBy? sortOrder;
  final SortOrder? sortDirection;
  final Function(
    DateTime? startDate,
    DateTime? endDate,
    TransactionSortBy? sortBy,
    SortOrder? sortDirection,
  ) onApplyFilter;

  const TransactionFilterBottomSheet({
    super.key,
    this.rangeStartDate,
    this.rangeEndDate,
    this.sortOrder,
    this.sortDirection,
    required this.onApplyFilter,
  });

  @override
  State<TransactionFilterBottomSheet> createState() => _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState extends State<TransactionFilterBottomSheet> {
  late DateTime? _rangeStartDate;
  late DateTime? _rangeEndDate;
  late List<TransactionStatus> _selectedStatuses;
  late TransactionSortBy? _sortOrder;
  late SortOrder? _sortDirection;

  @override
  void initState() {
    super.initState();
    _rangeStartDate = widget.rangeStartDate;
    _rangeEndDate = widget.rangeEndDate;
    _sortOrder = widget.sortOrder;
    _sortDirection = widget.sortDirection ?? SortOrder.desc;
  }

  void _applyFilters() {
    widget.onApplyFilter(
      _rangeStartDate,
      _rangeEndDate,
      _sortOrder,
      _sortDirection,
    );
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _rangeStartDate = null;
      _rangeEndDate = null;
      _selectedStatuses = [];
      _sortOrder = null;
      _sortDirection = SortOrder.desc;
    });
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime? selectedDate,
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
              initialDate: selectedDate ?? DateTime.now(),
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
                  selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(selectedDate)
                      : 'Select date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selectedDate != null
                            ? AppPallete.neutralColor.shade800
                            : AppPallete.neutralColor.shade500,
                      ),
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

  Widget _buildStatusSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPallete.neutralColor.shade700,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionStatus.values.map((status) {
            final isSelected = _selectedStatuses.contains(status);
            final statusName = status.name[0].toUpperCase() + status.name.substring(1);

            return FilterChip(
              selected: isSelected,
              label: Text(statusName),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedStatuses.add(status);
                  } else {
                    _selectedStatuses.remove(status);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppPallete.primaryColor.shade50,
              checkmarkColor: AppPallete.primaryColor,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppPallete.primaryColor.shade700
                        : AppPallete.neutralColor.shade700,
                  ),
              side: BorderSide(
                color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortBySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPallete.neutralColor.shade700,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppPallete.neutralColor.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<TransactionSortBy?>(
              value: _sortOrder,
              isExpanded: true,
              hint: Text(
                'Select sort order',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppPallete.neutralColor.shade500),
              ),
              buttonStyleData: ButtonStyleData(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                offset: const Offset(0, 8),
              ),
              items: [
                DropdownMenuItem<TransactionSortBy?>(
                  value: null,
                  child: Text(
                    'None',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ...TransactionSortBy.values.map<DropdownMenuItem<TransactionSortBy>>(
                  (TransactionSortBy value) {
                    final sortName = value.name[0].toUpperCase() + value.name.substring(1);
                    return DropdownMenuItem<TransactionSortBy>(
                      value: value,
                      child: Text(
                        sortName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  },
                ),
              ],
              onChanged: (TransactionSortBy? newValue) {
                setState(() {
                  _sortOrder = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortDirectionSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort Direction',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPallete.neutralColor.shade700,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<SortOrder>(
                title: Text(
                  'Ascending',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: SortOrder.asc,
                groupValue: _sortDirection,
                contentPadding: EdgeInsets.zero,
                activeColor: AppPallete.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _sortDirection = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<SortOrder>(
                title: Text(
                  'Descending',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: SortOrder.desc,
                groupValue: _sortDirection,
                contentPadding: EdgeInsets.zero,
                activeColor: AppPallete.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _sortDirection = value;
                  });
                },
              ),
            ),
          ],
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
              _rangeEndDate = now;
              _rangeStartDate = now.subtract(const Duration(days: 7));
            });
          },
        ),
        _buildPresetButton(
          '14 Hari Lalu',
          () {
            final now = DateTime.now();
            setState(() {
              _rangeEndDate = now;
              _rangeStartDate = now.subtract(const Duration(days: 14));
            });
          },
        ),
        _buildPresetButton(
          'Bulan ini',
          () {
            final now = DateTime.now();
            setState(() {
              _rangeEndDate = now;
              _rangeStartDate = DateTime(now.year, now.month, 1);
            });
          },
        ),
        _buildPresetButton(
          'Bulan Lalu',
          () {
            final now = DateTime.now();
            final lastMonth = DateTime(now.year, now.month - 1);
            setState(() {
              _rangeStartDate = DateTime(lastMonth.year, lastMonth.month, 1);
              _rangeEndDate = DateTime(now.year, now.month, 0);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Transaksi',
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
                  _rangeStartDate,
                  (newDate) {
                    setState(() {
                      _rangeStartDate = newDate;
                      if (_rangeEndDate != null &&
                          _rangeStartDate != null &&
                          _rangeEndDate!.isBefore(_rangeStartDate!)) {
                        _rangeEndDate = _rangeStartDate;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  context,
                  'Berakhir',
                  _rangeEndDate,
                  (newDate) {
                    setState(() {
                      _rangeEndDate = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPresetButtons(context),
          // const SizedBox(height: 24),
          // _buildStatusSelector(context),
          const SizedBox(height: 24),
          _buildSortBySelector(context),
          if (_sortOrder != null) ...[
            const SizedBox(height: 24),
            _buildSortDirectionSelector(context),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppPallete.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(color: AppPallete.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _applyFilters,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPallete.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
