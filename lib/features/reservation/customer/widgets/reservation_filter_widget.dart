import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/customer/viewstate/get_reservations_history_query_state.dart';
import 'package:socieaty/features/reservation/enum/reservation_sort_by_enum.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';

Future<GetReservationsHistoryQueryState?> showReservationFilterBottomSheet(
    BuildContext context, GetReservationsHistoryQueryState filterState) async {
  final result = await showModalBottomSheet<GetReservationsHistoryQueryState>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return ReservationFilterWidget(initialFilterState: filterState);
    },
  );
  return result;
}

class ReservationFilterWidget extends ConsumerStatefulWidget {
  final GetReservationsHistoryQueryState initialFilterState;

  const ReservationFilterWidget({
    super.key,
    required this.initialFilterState,
  });

  @override
  ConsumerState<ReservationFilterWidget> createState() => _ReservationFilterWidgetState();
}

class _ReservationFilterWidgetState extends ConsumerState<ReservationFilterWidget> {
  late ReservationSortBy? _selectedSortBy;
  late SortOrder? _selectedSortOrder;
  late GetReservationsHistoryQueryState _filterState;

  final List<Map<String, dynamic>> _sortByOptions = [
    {'value': ReservationSortBy.reservationTime, 'label': 'Tanggal Reservasi'},
    {'value': ReservationSortBy.createdAt, 'label': 'Tanggal Dibuat'},
    {'value': ReservationSortBy.finishedAt, 'label': 'Tanggal Selesai'},
  ];

  final List<Map<String, dynamic>> _sortOrderOptions = [
    {'value': SortOrder.asc, 'label': 'Terlama ke Terbaru'},
    {'value': SortOrder.desc, 'label': 'Terbaru ke Terlama'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.initialFilterState.sortBy;
    _selectedSortOrder = widget.initialFilterState.sortOrder;
    _filterState = widget.initialFilterState;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    void applyFilter() {
      final updatedFilter = _filterState.copyWith(
        sortBy: _selectedSortBy,
        sortOrder: _selectedSortOrder,
      );
      context.pop(updatedFilter);
    }

    void resetFilter() {
      setState(() {
        _selectedSortBy = null;
        _selectedSortOrder = null;
      });
    }

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: AppPallete.neutralColor.shade50,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: AppPallete.neutralColor.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Reservasi',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const DottedDivider(
                      height: 0.5,
                      color: AppPallete.neutralColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Urutkan Berdasarkan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._sortByOptions.map(
                      (option) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _selectedSortBy == option['value']
                              ? AppPallete.primaryColor.withAlpha(25)
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppPallete.neutralColor.shade200.withAlpha(127),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: RadioListTile<ReservationSortBy>(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          title: Text(
                            option['label'],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _selectedSortBy == option['value']
                                      ? AppPallete.primaryColor
                                      : AppPallete.neutralColor.shade800,
                                ),
                          ),
                          value: option['value'],
                          groupValue: _selectedSortBy,
                          onChanged: (value) {
                            setState(() {
                              _selectedSortBy = value;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          activeColor: AppPallete.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Urutan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._sortOrderOptions.map(
                      (option) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _selectedSortOrder == option['value']
                              ? AppPallete.primaryColor.withAlpha(25)
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppPallete.neutralColor.shade200.withAlpha(127),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: RadioListTile<SortOrder>(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          title: Text(
                            option['label'],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _selectedSortOrder == option['value']
                                      ? AppPallete.primaryColor
                                      : AppPallete.neutralColor.shade800,
                                ),
                          ),
                          value: option['value'],
                          groupValue: _selectedSortOrder,
                          onChanged: (value) {
                            setState(() {
                              _selectedSortOrder = value;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          activeColor: AppPallete.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppPallete.neutralColor.shade200.withAlpha(127),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: resetFilter,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppPallete.primaryColor),
                    ),
                    child: Text('Reset', style: TextStyle(color: AppPallete.primaryColor)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: applyFilter,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
