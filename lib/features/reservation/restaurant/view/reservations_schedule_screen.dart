import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/customer/model/customer_data.dart';
import 'package:socieaty/features/restaurant/model/restaurant_data.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
              context.push('/restaurant/dashboard/reservation/view/calender', extra: widget.reservationConfig);
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
            _buildFilterChip(ReservationStatus.cancelled, 'Cancelled'),
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
    final filteredReservations = _getFilteredReservations();

    if (filteredReservations.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 70,
                color: AppPallete.neutralColor.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                _selectedStatusFilter == null
                    ? 'No reservations for this date'
                    : 'No ${_selectedStatusFilter!.name} reservations',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppPallete.neutralColor.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group reservations by time
    final Map<String, List<Reservation>> reservationsByTime = {};
    for (var reservation in filteredReservations) {
      final timeKey = DateFormat('HH:mm').format(reservation.reservationTime);
      if (!reservationsByTime.containsKey(timeKey)) {
        reservationsByTime[timeKey] = [];
      }
      reservationsByTime[timeKey]!.add(reservation);
    }

    // Sort time keys
    final sortedTimeKeys = reservationsByTime.keys.toList()..sort();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final timeKey = sortedTimeKeys[index];
            final reservationsForTime = reservationsByTime[timeKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8, top: index > 0 ? 16 : 0, left: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppPallete.primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          timeKey,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppPallete.primaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reservationsForTime.length} ${reservationsForTime.length > 1 ? 'reservations' : 'reservation'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppPallete.neutralColor.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ...reservationsForTime.map(
                  (reservation) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildReservationCard(context, reservation),
                  ),
                ),
              ],
            );
          },
          childCount: sortedTimeKeys.length,
        ),
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, Reservation reservation) {
    Color statusColor = reservation.reservationStatus.getStatusColor();

    final durationInMinutes =
        reservation.endTimeEstimation.difference(reservation.reservationTime).inMinutes;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.withAlpha(128),
            blurRadius: 2,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer avatar
                  CircleAvatar(
                    backgroundColor: AppPallete.neutralColor.shade100,
                    radius: 20,
                    child: Text(
                      reservation.customer.name.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: AppPallete.neutralColor.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Customer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reservation.customer.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppPallete.neutralColor.shade800,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(40),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                reservation.reservationStatus.name.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Reservation details
                        Row(
                          children: [
                            _buildInfoItem(
                              Icons.timer_outlined,
                              '$durationInMinutes min',
                              AppPallete.primaryColor,
                            ),
                            const SizedBox(width: 16),
                            _buildInfoItem(
                              Icons.people_outline,
                              '${reservation.peopleSize}',
                              AppPallete.neutralColor.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildInfoItem(
                              Icons.phone_outlined,
                              reservation.customer.phoneNumber,
                              AppPallete.neutralColor.shade600,
                            ),
                          ],
                        ),
                        if (reservation.note.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 14,
                                color: AppPallete.neutralColor.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  reservation.note,
                                  style: TextStyle(
                                    color: AppPallete.neutralColor.shade600,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Status indicator
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Reservation> _getFilteredReservations() {
    final date = _selectedDate;
    final formattedSelectedDate = DateFormat('yyyy-MM-dd').format(date);

    // First filter by date
    final dateFilteredReservations = dummyReservations.where((reservation) {
      final formattedReservationDate = DateFormat('yyyy-MM-dd').format(reservation.reservationTime);
      return formattedReservationDate == formattedSelectedDate;
    }).toList();

    // Then exclude pending reservations (only show confirmed, completed, or cancelled)
    final statusFilteredReservations = dateFilteredReservations.where((reservation) {
      return reservation.reservationStatus != ReservationStatus.pending;
    }).toList();

    // Then apply additional status filter if selected
    if (_selectedStatusFilter == null) {
      return statusFilteredReservations;
    }

    return statusFilteredReservations
        .where((reservation) => reservation.reservationStatus == _selectedStatusFilter)
        .toList();
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

// Dummy reservation data
final List<Reservation> dummyReservations = [
  Reservation(
    transactionId: '1001',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 150000,
    serviceFee: 15000,
    note: 'Window seat preferred',
    status: TransactionStatus.success,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust001',
      name: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd001',
        wallet: 1000000,
      ),
    ),
    reservationId: 'rsv001',
    reservationStatus: ReservationStatus.confirmed,
    reservationTime: DateTime.now().add(const Duration(hours: 1)),
    endTimeEstimation: DateTime.now().add(const Duration(hours: 3)),
    peopleSize: 2,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    finishedAt: null,
  ),

  Reservation(
    transactionId: '1002',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 300000,
    serviceFee: 30000,
    note: 'Birthday celebration',
    status: TransactionStatus.success,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust002',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phoneNumber: '234-567-8901',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd002',
        wallet: 850000,
      ),
    ),
    reservationId: 'rsv002',
    reservationStatus: ReservationStatus.pending,
    reservationTime: DateTime.now().add(const Duration(hours: 4)),
    endTimeEstimation: DateTime.now().add(const Duration(hours: 6)),
    peopleSize: 4,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    finishedAt: null,
  ),

  Reservation(
    transactionId: '1003',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 500000,
    serviceFee: 50000,
    note: 'Business meeting',
    status: TransactionStatus.success,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust003',
      name: 'Robert Johnson',
      email: 'robert@example.com',
      phoneNumber: '345-678-9012',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd003',
        wallet: 1200000,
      ),
    ),
    reservationId: 'rsv003',
    reservationStatus: ReservationStatus.confirmed,
    reservationTime: DateTime.now().add(const Duration(hours: 5)),
    endTimeEstimation: DateTime.now().add(const Duration(hours: 7)),
    peopleSize: 6,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    finishedAt: null,
  ),

  Reservation(
    transactionId: '1004',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 200000,
    serviceFee: 20000,
    note: '',
    status: TransactionStatus.success,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust004',
      name: 'Emily Wilson',
      email: 'emily@example.com',
      phoneNumber: '456-789-0123',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd004',
        wallet: 750000,
      ),
    ),
    reservationId: 'rsv004',
    reservationStatus: ReservationStatus.confirmed,
    reservationTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
    endTimeEstimation: DateTime.now().add(const Duration(days: 1, hours: 4)),
    peopleSize: 3,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    finishedAt: null,
  ),

  Reservation(
    transactionId: '1005',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 180000,
    serviceFee: 18000,
    note: 'Quiet section preferred',
    status: TransactionStatus.success,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust005',
      name: 'Michael Brown',
      email: 'michael@example.com',
      phoneNumber: '567-890-1234',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd005',
        wallet: 950000,
      ),
    ),
    reservationId: 'rsv005',
    reservationStatus: ReservationStatus.pending,
    reservationTime: DateTime.now().add(const Duration(days: 1, hours: 6)),
    endTimeEstimation: DateTime.now().add(const Duration(days: 1, hours: 8)),
    peopleSize: 2,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    finishedAt: null,
  ),

  Reservation(
    transactionId: '1006',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 800000,
    serviceFee: 80000,
    note: 'Family gathering',
    status: TransactionStatus.success,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust006',
      name: 'Lisa Anderson',
      email: 'lisa@example.com',
      phoneNumber: '678-901-2345',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd006',
        wallet: 1500000,
      ),
    ),
    reservationId: 'rsv006',
    reservationStatus: ReservationStatus.confirmed,
    reservationTime: DateTime.now().add(const Duration(days: 2, hours: 7)),
    endTimeEstimation: DateTime.now().add(const Duration(days: 2, hours: 10)),
    peopleSize: 8,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    finishedAt: null,
  ),

  Reservation(
    transactionId: '1007',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 450000,
    serviceFee: 45000,
    note: 'Vegetarian options required',
    status: TransactionStatus.failed,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust007',
      name: 'David Taylor',
      email: 'david@example.com',
      phoneNumber: '789-012-3456',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd007',
        wallet: 1100000,
      ),
    ),
    reservationId: 'rsv007',
    reservationStatus: ReservationStatus.cancelled,
    reservationTime: DateTime.now().add(const Duration(days: 3, hours: 6)),
    endTimeEstimation: DateTime.now().add(const Duration(days: 3, hours: 8)),
    peopleSize: 5,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    finishedAt: null,
  ),

  // Same day reservations with different times
  Reservation(
    transactionId: '1008',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 200000,
    serviceFee: 20000,
    note: 'Anniversary dinner',
    status: TransactionStatus.success,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust008',
      name: 'Sarah Lee',
      email: 'sarah@example.com',
      phoneNumber: '890-123-4567',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd008',
        wallet: 900000,
      ),
    ),
    reservationId: 'rsv008',
    reservationStatus: ReservationStatus.confirmed,
    reservationTime: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
    endTimeEstimation: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
    peopleSize: 2,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    finishedAt: null,
  ),

  Reservation(
    transactionId: '1009',
    serviceType: TransactionServiceType.reservation,
    grossAmount: 350000,
    serviceFee: 35000,
    note: 'Allergy to shellfish',
    status: TransactionStatus.success,
    restaurant: SocieatyRestaurant(
      id: 'rest001',
      name: 'Delicious Bistro',
      email: 'delicious@example.com',
      phoneNumber: '123-456-7890',
      role: UserRole.restaurant,
      restaurantData: RestaurantData(
        id: 'rd001',
        restaurantBannerUrl: 'https://example.com/banner.jpg',
        location: const LatLng(-6.2088, 106.8456),
        themes: [],
        payoutBank: BankEnum.mandiri,
        accountNumber: '1234567890',
        openTime: '08:00',
        closeTime: '22:00',
        isReservationAvailable: true,
      ),
    ),
    customer: SocieatyCustomer(
      id: 'cust009',
      name: 'Thomas White',
      email: 'thomas@example.com',
      phoneNumber: '901-234-5678',
      role: UserRole.customer,
      customerData: const CustomerData(
        id: 'cd009',
        wallet: 1250000,
      ),
    ),
    reservationId: 'rsv009',
    reservationStatus: ReservationStatus.confirmed,
    reservationTime: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
    endTimeEstimation: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
    peopleSize: 4,
    menuItems: [],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    finishedAt: null,
  ),
];
