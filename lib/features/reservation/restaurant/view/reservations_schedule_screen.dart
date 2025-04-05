import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/repository/request/get_reservations_query.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_list.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/shared/widgets/custom_date_picker.dart';

class ReservationsScheduleScreen extends StatefulWidget {
  final ReservationConfig reservationConfig;
  const ReservationsScheduleScreen({super.key, required this.reservationConfig});

  @override
  State<ReservationsScheduleScreen> createState() => _ReservationsScheduleScreenState();
}

class _ReservationsScheduleScreenState extends State<ReservationsScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  ReservationStatus? _selectedStatusFilter;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  bool _isAlmostCollapsed = false;
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureHeaderHeight();
    });
  }

  void _measureHeaderHeight() {
    final RenderBox? renderBox = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    if (size != null) {
      setState(() {
        _headerHeight = size.height;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    double collapsedPercentage = _scrollController.offset / _headerHeight;

    if (mounted) {
      if (collapsedPercentage >= 1 && !_isAlmostCollapsed) {
        setState(() {
          _isAlmostCollapsed = true;
        });
      } else if (collapsedPercentage < 1 && _isAlmostCollapsed) {
        setState(() {
          _isAlmostCollapsed = false;
        });
      }
      if (collapsedPercentage >= 1 && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (collapsedPercentage < 1 && _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.neutralColor.shade50,
        surfaceTintColor: Colors.transparent,
        title: _isAlmostCollapsed
            ? Text('Reservations',
                style:
                    Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
            : null,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/restaurant/dashboard/reservation/view/calender',
                  extra: widget.reservationConfig);
            },
            icon: const Icon(Icons.calendar_month),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      key: _headerKey,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Text(
                            'Reservations',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('EEEE, d MMMM').format(_selectedDate),
                            style: TextStyle(
                              color: AppPallete.neutralColor.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    floating: false,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: AppPallete.neutralColor.shade50,
                    expandedHeight: 110,
                    toolbarHeight: 110,
                    title: const Text(""),
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildDatePicker(),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverStatusFilterDelegate(
                      child: _buildStatusFilter(),
                    ),
                  ),
                  _buildSliverReservationsList(),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return CustomDatePicker(
      initialDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFilterChip(null, 'All'),
            _buildFilterChip(ReservationStatus.confirmed, 'Confirmed'),
            _buildFilterChip(ReservationStatus.completed, 'Completed'),
            _buildFilterChip(ReservationStatus.canceled, 'Cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(ReservationStatus? status, String label) {
    final isSelected = _selectedStatusFilter == status;
    Color chipColor;
    if (status == null) {
      chipColor = AppPallete.primaryColor;
    } else {
      chipColor = status.getStatusColor();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedStatusFilter = selected ? status : null;
          });
        },
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        selectedColor: chipColor,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        side: BorderSide(
          color: isSelected ? chipColor : AppPallete.neutralColor.shade300,
        ),
      ),
    );
  }

  Widget _buildSliverReservationsList() {
    List<ReservationStatus> statusFilter = [];
    if (_selectedStatusFilter != null) {
      statusFilter.add(_selectedStatusFilter!);
    } else {
      statusFilter = [
        ReservationStatus.confirmed,
        ReservationStatus.completed,
        ReservationStatus.canceled,
      ];
    }

    // Normalize date to the start of the day to prevent timezone issues
    final DateTime normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      0,
      0,
      0,
    );

    debugPrint('Date: $normalizedDate');

    final query = GetReservationsQuery(
      restaurantId: widget.reservationConfig.restaurantId,
      reservationStatus: statusFilter,
      reservationTime: normalizedDate,
    );

    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 300,
        child: ReservationList(query: query),
      ),
    );
  }
}

class _SliverStatusFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverStatusFilterDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppPallete.neutralColor.shade50,
      child: child,
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
