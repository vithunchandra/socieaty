import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/customer/widgets/customer_paginated_reservation_list.dart';
import 'package:socieaty/features/reservation/enum/reservation_sort_by_enum.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/repository/request/paginate_reservations_query.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

class ReservationsHistoryScreen extends ConsumerStatefulWidget {
  const ReservationsHistoryScreen({super.key});

  @override
  ConsumerState<ReservationsHistoryScreen> createState() => _ReservationsHistoryScreenState();
}

class _ReservationsHistoryScreenState extends ConsumerState<ReservationsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<ReservationStatus> _activeStatuses = [
    ReservationStatus.pending,
    ReservationStatus.confirmed,
  ];

  final List<ReservationStatus> _pastStatuses = [
    ReservationStatus.completed,
    ReservationStatus.canceled,
    ReservationStatus.rejected
  ];

  late PaginateReservationsQuery _activePaginationQuery;
  late PaginateReservationsQuery _pastPaginationQuery;

  // Keys to force rebuild of lists when filters change
  int _activeQueryVersion = 0;
  int _pastQueryVersion = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializePaginationQueries();
  }

  void _initializePaginationQueries() {
    final user = ref.read(authLocalRepositoryProvider).getUserData();
    final customerId = user?.customerData?.id;

    _activePaginationQuery = PaginateReservationsQuery(
      customerId: customerId,
      reservationStatus: _activeStatuses,
      paginationQuery: const PaginationQuery(offset: 0, limit: 5),
    );

    _pastPaginationQuery = PaginateReservationsQuery(
      customerId: customerId,
      reservationStatus: _pastStatuses,
      paginationQuery: const PaginationQuery(offset: 0, limit: 5),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppPallete.neutralColor.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reservasi Saya',
          style: textTheme.titleLarge?.copyWith(
            color: AppPallete.neutralColor.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: AppPallete.neutralColor.shade800),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8, bottom: 0),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              labelColor: AppPallete.primaryColor,
              unselectedLabelColor: AppPallete.neutralColor.shade600,
              indicatorColor: AppPallete.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppPallete.primaryColor,
                    width: 3,
                  ),
                ),
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return states.contains(WidgetState.focused) ? null : Colors.transparent;
                },
              ),
              labelStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onTap: (_) {
                // Force rebuild when tab changes
                setState(() {});
              },
              tabs: const [
                Tab(
                  text: 'Reservasi Aktif',
                ),
                Tab(
                  text: 'Riwayat Reservasi',
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppPallete.neutralColor.shade200,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Use key based on query version to force rebuild when filters change
                CustomerPaginatedReservationList(
                  key: ValueKey('active_reservations_$_activeQueryVersion'),
                  query: _activePaginationQuery,
                  isActiveTab: true,
                  onRefresh: () {
                    // Reset pagination and refresh
                    setState(() {
                      _initializePaginationQueries();
                      _activeQueryVersion++;
                    });
                  },
                ),
                CustomerPaginatedReservationList(
                  key: ValueKey('past_reservations_$_pastQueryVersion'),
                  query: _pastPaginationQuery,
                  isActiveTab: false,
                  onRefresh: () {
                    // Reset pagination and refresh
                    setState(() {
                      _initializePaginationQueries();
                      _pastQueryVersion++;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final isActiveTab = _tabController.index == 0;
    final currentQuery = isActiveTab ? _activePaginationQuery : _pastPaginationQuery;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildFilterBottomSheet(context, currentQuery, isActiveTab);
      },
    );
  }

  Widget _buildFilterBottomSheet(
      BuildContext context, PaginateReservationsQuery query, bool isActiveTab) {
    final screenHeight = MediaQuery.of(context).size.height;
    ReservationSortBy? selectedSortBy = query.sortBy;
    SortOrder? selectedSortOrder = query.sortOrder;

    return StatefulBuilder(
      builder: (context, setState) {
        void applyFilter() {
          final updatedQuery = query.copyWith(
            sortBy: selectedSortBy,
            sortOrder: selectedSortOrder,
          );

          this.setState(() {
            if (isActiveTab) {
              _activePaginationQuery = updatedQuery;
              _activeQueryVersion++; // Increment version to force rebuild
            } else {
              _pastPaginationQuery = updatedQuery;
              _pastQueryVersion++; // Increment version to force rebuild
            }
          });

          Navigator.pop(context);
        }

        void resetFilter() {
          setState(() {
            selectedSortBy = null;
            selectedSortOrder = null;
          });
        }

        final List<Map<String, dynamic>> sortByOptions = [
          {'value': ReservationSortBy.reservationTime, 'label': 'Tanggal Reservasi'},
          {'value': ReservationSortBy.createdAt, 'label': 'Tanggal Dibuat'},
          {'value': ReservationSortBy.finishedAt, 'label': 'Tanggal Selesai'},
        ];

        final List<Map<String, dynamic>> sortOrderOptions = [
          {'value': SortOrder.asc, 'label': 'Terlama ke Terbaru'},
          {'value': SortOrder.desc, 'label': 'Terbaru ke Terlama'},
        ];

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
                        Divider(color: AppPallete.neutralColor.shade300),
                        const SizedBox(height: 24),
                        Text(
                          'Urutkan Berdasarkan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...sortByOptions.map(
                          (option) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selectedSortBy == option['value']
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
                                      color: selectedSortBy == option['value']
                                          ? AppPallete.primaryColor
                                          : AppPallete.neutralColor.shade800,
                                    ),
                              ),
                              value: option['value'],
                              groupValue: selectedSortBy,
                              onChanged: (value) {
                                setState(() {
                                  selectedSortBy = value;
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
                        ...sortOrderOptions.map(
                          (option) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selectedSortOrder == option['value']
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
                                      color: selectedSortOrder == option['value']
                                          ? AppPallete.primaryColor
                                          : AppPallete.neutralColor.shade800,
                                    ),
                              ),
                              value: option['value'],
                              groupValue: selectedSortOrder,
                              onChanged: (value) {
                                setState(() {
                                  selectedSortOrder = value;
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: resetFilter,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppPallete.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(color: AppPallete.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: applyFilter,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppPallete.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Terapkan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
