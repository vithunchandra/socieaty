import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/reservation/customer/socket/customer_reservation_socket_service.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/customer/view/states/active_reservation_view.dart';
import 'package:socieaty/features/reservation/customer/view/states/cancelled_reservation_screen.dart';
import 'package:socieaty/features/reservation/customer/view/states/completed_reservation_screen.dart';
import 'package:socieaty/features/reservation/customer/view/states/error_view.dart';
import 'package:socieaty/features/reservation/customer/view/states/loading_view.dart';
import 'package:socieaty/features/reservation/provider/get_reservation_provider.dart';
import 'package:socieaty/features/reservation/repository/reservation_repository.dart';

class TrackReservationScreen extends ConsumerStatefulWidget {
  final String reservationId;

  const TrackReservationScreen({
    super.key,
    required this.reservationId,
  });

  @override
  ConsumerState<TrackReservationScreen> createState() => _TrackReservationScreenState();
}

class _TrackReservationScreenState extends ConsumerState<TrackReservationScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  late CustomerReservationSocketService _socketService;
  Reservation? _reservationData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

    _socketService = ref.read(customerReservationSocketServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _removeSocketListeners();
    super.dispose();
  }

  void _setupSocketListeners() {
    _socketService.initConnection();
    _socketService.listenReservationUpdate(widget.reservationId, _handleReservationUpdate);
    ref.read(reservationRepositoryProvider).trackReservation(widget.reservationId).then((value) {
      switch (value) {
        case Success(data: final data):
          debugPrint('Reservation tracked: ${data.message}');
        case Error(error: final error):
          debugPrint('Error tracking reservation: $error');
      }
    });
  }

  void _removeSocketListeners() {
    _socketService.removeListener('track-reservation');
  }

  void _handleReservationUpdate(dynamic data) {
    debugPrint('Received reservation update: $data');

    try {
      final updatedReservation = Reservation.fromJson(data);

      if (updatedReservation.reservationId == widget.reservationId) {
        if (mounted) {
          setState(() {
            _reservationData = updatedReservation;
            _isLoading = false;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error processing reservation update: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error processing reservation data';
          _isLoading = false;
        });
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final double offset = _scrollController.offset;
    final threshold = 100.0;
    final isCollapsed = offset > threshold;

    if (isCollapsed != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
    }
  }

  void _showRateRestaurantDialog() {
    showSnackbar(context, 'Fitur penilaian restoran akan diimplementasikan secara terpisah',
        state: SnackbarState.info);
  }

  void _showContactSupportDialog() {
    showSnackbar(context, 'Fitur layanan pelanggan akan diimplementasikan secara terpisah',
        state: SnackbarState.info);
  }

  void _handleRetry() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _setupSocketListeners();
    ref.invalidate(getReservationProvider(widget.reservationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Lacak Reservasi #${widget.reservationId.substring(0, 8)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_errorMessage != null && _reservationData == null) {
      return ErrorView(
        errorMessage: _errorMessage ?? 'Tidak dapat memuat data reservasi',
        onRetry: _handleRetry,
      );
    }

    if (_reservationData != null) {
      return _buildReservationContent(_reservationData!);
    }

    return ref.watch(getReservationProvider(widget.reservationId)).when(
          data: (reservation) {
            _reservationData = reservation;
            return _buildReservationContent(reservation);
          },
          loading: () => const LoadingView(),
          error: (error, stackTrace) => ErrorView(
            errorMessage: error.toString(),
            onRetry: _handleRetry,
          ),
        );
  }

  Widget _buildReservationContent(Reservation reservation) {
    if (reservation.reservationStatus == ReservationStatus.completed) {
      return CompletedReservationScreen(
        reservation: reservation,
        onBackToHome: () => context.pop(),
        onRateRestaurant: _showRateRestaurantDialog,
      );
    } else if (reservation.reservationStatus == ReservationStatus.cancelled) {
      return CancelledReservationScreen(
        reservation: reservation,
        onBackToHome: () => context.pop(),
        onContactSupport: _showContactSupportDialog,
      );
    } else {
      return ActiveReservationView(
        reservation: reservation,
        onCancel: () => {},
        onReschedule: () => {},
        onShowQR: () => {},
      );
    }
  }
}
