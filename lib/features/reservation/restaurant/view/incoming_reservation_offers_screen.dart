import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/qr_code_scanner/view/qr_code_scanner_screen.dart';
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
    // Add listener to update UI when tab changes
    _tabController.addListener(() {
      setState(() {});
    });
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
        onPressed: () async {
          final result = await context.push(
            '/qr-code-scanner',
            extra: const QrCodeScannerArgs(
              title: 'Scan Reservation QR',
              helperMessage: 'Scan customer QR code to check-in',
            ),
          );

          if (result != null && result is String) {
            debugPrint("Scanned QR code: $result");
            // Process the scanned QR code here if needed
          }
        },
        backgroundColor: AppPallete.primaryColor,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      );
    }
    return const SizedBox.shrink();
  }

  // Future<void> _handleScannedQrCode(String code) async {
  //   String? reservationId;

  //   // Try to extract reservation ID from URL or use directly
  //   final backendUrl = Uri.parse(code).authority;
  //   if (code.contains('/reservation/')) {
  //     reservationId = code.split('/reservation/').last.split('/').first;
  //   } else {
  //     reservationId = code;
  //   }

  //   if (reservationId.isEmpty) {
  //     _showMessage('Invalid QR code format', SnackbarState.error);
  //     return;
  //   }

  //   try {
  //     // Get reservation details
  //     final result = await ref.read(reservationRepositoryProvider).getReservation(reservationId);

  //     switch (result) {
  //       case Success(data: final data):
  //         final reservation = data.reservation;

  //         // Check if reservation is in confirmed status
  //         if (reservation.reservationStatus != ReservationStatus.confirmed) {
  //           if (reservation.reservationStatus == ReservationStatus.completed) {
  //             _showMessage('Reservation has already been completed', SnackbarState.info);
  //           } else {
  //             _showMessage('Reservation is not in confirmed status', SnackbarState.error);
  //           }
  //           return;
  //         }

  //         // Update reservation to completed status
  //         await _updateReservationStatus(reservationId);
  //         break;
  //       case Error(error: final error):
  //         _showMessage('Failed to load reservation: ${error.message}', SnackbarState.error);
  //         break;
  //     }
  //   } catch (e) {
  //     _showMessage('An error occurred: $e', SnackbarState.error);
  //   }
  // }

  // Future<void> _updateReservationStatus(String reservationId) async {
  //   // Listen for updates
  //   ref.listen(updateReservationStatusViewModelProvider(reservationId), (previous, next) {
  //     switch (next.updatedReservation) {
  //       case SuccessState():
  //         _showMessage('Reservation checked-in successfully!', SnackbarState.success);
  //         // Refresh the list
  //         ref.invalidate(getRestaurantReservationsProvider([ReservationStatus.confirmed]));
  //         ref.invalidate(getRestaurantReservationsProvider([ReservationStatus.completed]));
  //       case ErrorState(message: var message):
  //         _showMessage('Failed to update reservation: $message', SnackbarState.error);
  //       case LoadingState():
  //       case IdleState():
  //         break;
  //     }
  //   });

  //   // Update the reservation status to completed
  //   await ref
  //       .read(updateReservationStatusViewModelProvider(reservationId).notifier)
  //       .updateReservationStatus(ReservationStatus.completed);
  // }

  // void _showMessage(String message, SnackbarState state) {
  //   if (context.mounted) {
  //     showSnackbar(context, message, state: state);
  //   }
  // }
}
