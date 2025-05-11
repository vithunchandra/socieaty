import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/qr_code_scanner/view/qr_code_scanner_screen.dart';
import 'package:socieaty/features/reservation/customer/view/states/loading_view.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/provider/get_reservation_provider.dart';
import 'package:socieaty/features/reservation/provider/get_reservations_provider.dart';
import 'package:socieaty/features/reservation/repository/request/get_reservations_query.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_details_sheet.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_list.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

class ReservationManagementScreen extends ConsumerStatefulWidget {
  final Reservation? initialReservation;

  const ReservationManagementScreen({super.key, this.initialReservation});

  @override
  ConsumerState<ReservationManagementScreen> createState() => _ReservationManagementScreenState();
}

class _ReservationManagementScreenState extends ConsumerState<ReservationManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isScanning = false;
  late SocieatyRestaurant _owner;
  late GetReservationsQuery _pendingQuery;
  late GetReservationsQuery _confirmedQuery;
  late GetReservationsQuery _diningQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _owner = UserConverter.userToRestaurant(ref.read(authLocalRepositoryProvider).getUserData()!);
    _pendingQuery = GetReservationsQuery(
      restaurantId: _owner.restaurantData.id,
      reservationStatus: [ReservationStatus.pending],
    );
    _confirmedQuery = GetReservationsQuery(
      restaurantId: _owner.restaurantData.id,
      reservationStatus: [ReservationStatus.confirmed],
    );
    _diningQuery = GetReservationsQuery(
      restaurantId: _owner.restaurantData.id,
      reservationStatus: [ReservationStatus.dining],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleReservationScan(BuildContext context) async {
    final result = await context.push(
      '/qr-code-scanner',
      extra: const QrCodeScannerArgs(
        title: 'Scan QR Reservasi',
        helperMessage: 'Scan kode QR pelanggan untuk check-in',
      ),
    );

    if (result == null) {
      if (context.mounted) {
        showSnackbar(context, 'QR code scan gagal', state: SnackbarState.error);
      }
      return;
    }

    if (result is! String) {
      if (context.mounted) {
        showSnackbar(context, 'QR code tidak valid', state: SnackbarState.error);
      }
      return;
    }

    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    final reservationId = result.toString();

    try {
      final reservation = await ref.watch(getReservationProvider(reservationId).future);
      if (reservation.reservationStatus != ReservationStatus.confirmed) {
        if (context.mounted) {
          showSnackbar(context, 'Status reservasi tidak valid', state: SnackbarState.error);
        }
        return;
      }

      return _showReservationDetails(reservation);
    } catch (err) {
      if (context.mounted) {
        showSnackbar(context, 'Reservasi tidak ditemukan', state: SnackbarState.error);
      }
      return;
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
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
          onUpdatedReservation: (reservation) {
            ref.invalidate(getReservationsProvider(_pendingQuery));
            ref.invalidate(getReservationsProvider(_confirmedQuery));
            ref.invalidate(getReservationsProvider(_diningQuery));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Reservasi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        centerTitle: true,
        backgroundColor: AppPallete.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Riwayat Reservasi',
            onPressed: () {
              context.push('/restaurant/dashboard/reservation/manage/history');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(178),
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Terkonfirmasi'),
            Tab(text: 'Makan'),
          ],
        ),
      ),
      body: _isScanning
          ? const LoadingView()
          : TabBarView(
              controller: _tabController,
              children: [
                ReservationList(
                  query: _pendingQuery,
                ),
                ReservationList(
                  query: _confirmedQuery,
                ),
                ReservationList(
                  query: _diningQuery,
                ),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return StatefulBuilder(builder: (context, setState) {
      _tabController.addListener(() {
        setState(() {});
      });
      return _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                _handleReservationScan(context);
              },
              backgroundColor: AppPallete.primaryColor,
              child: const Icon(Icons.qr_code_scanner, color: Colors.white),
            )
          : const SizedBox.shrink();
    });
  }
}
