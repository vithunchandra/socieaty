import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_details_sheet.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_list.dart';

class IncomingReservationOffersScreen extends ConsumerStatefulWidget {
  final Reservation? initialReservation;

  const IncomingReservationOffersScreen({super.key, this.initialReservation});

  @override
  ConsumerState<IncomingReservationOffersScreen> createState() =>
      _IncomingReservationOffersScreenState();
}

class _IncomingReservationOffersScreenState extends ConsumerState<IncomingReservationOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // If there's an initial reservation, go to the appropriate tab
    if (widget.initialReservation != null) {
      if (widget.initialReservation!.reservationStatus == ReservationStatus.confirmed) {
        _tabController.animateTo(1);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showReservationDetails(Reservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ReservationDetailsSheet(
          reservation: reservation,
          scrollController: scrollController,
          statusFilter: [reservation.reservationStatus],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Reservations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        centerTitle: true,
        backgroundColor: AppPallete.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(178),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReservationList(status: [ReservationStatus.pending]),
          ReservationList(status: [ReservationStatus.confirmed]),
          ReservationList(status: [ReservationStatus.completed]),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    // Only show the FAB when on the "Confirmed" tab
    if (_tabController.index == 1) {
      return FloatingActionButton(
        onPressed: () {
          context.push('/qr-code-scanner');
        },
        backgroundColor: AppPallete.primaryColor,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      );
    }
    return const SizedBox.shrink();
  }
}
