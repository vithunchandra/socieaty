import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/customer/provider/get_customer_reservations_provider.dart';
import 'package:socieaty/features/reservation/customer/viewstate/get_reservations_history_query_state.dart';
import 'package:socieaty/features/reservation/customer/widgets/reservation_filter_widget.dart';
import 'package:socieaty/features/reservation/customer/widgets/reservation_list.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';

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
    ReservationStatus.cancelled,
    ReservationStatus.rejected
  ];

  late GetReservationsHistoryQueryState _activeQueryState;
  late GetReservationsHistoryQueryState _pastQueryState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _activeQueryState = GetReservationsHistoryQueryState(reservationStatus: _activeStatuses);
    _pastQueryState = GetReservationsHistoryQueryState(reservationStatus: _pastStatuses);
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
              final isActiveTab = _tabController.index == 0;
              final currentQuery = isActiveTab ? _activeQueryState : _pastQueryState;

              showReservationFilterBottomSheet(context, currentQuery).then((result) {
                if (result != null) {
                  setState(() {
                    if (isActiveTab) {
                      _activeQueryState = result;
                    } else {
                      _pastQueryState = result;
                    }
                  });

                  // Refresh data with new filters
                  ref.invalidate(getCustomerReservationsProvider(
                      isActiveTab ? _activeQueryState : _pastQueryState));
                }
              });
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
                // Force rebuild when tab changes to update filter state
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
                ReservationList(
                  queryState: _activeQueryState,
                  isActiveTab: true,
                  onRefresh: () =>
                      ref.invalidate(getCustomerReservationsProvider(_activeQueryState)),
                ),
                ReservationList(
                  queryState: _pastQueryState,
                  isActiveTab: false,
                  onRefresh: () => ref.invalidate(getCustomerReservationsProvider(_pastQueryState)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
