import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/restaurant/provider/get_restaurant_reservations_provider.dart';
import 'package:socieaty/features/reservation/restaurant/provider/new_reservation_notification_provider.dart';
import 'package:socieaty/features/reservation/restaurant/provider/reservation_changes_notification_provider.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_card.dart';

class ReservationList extends ConsumerStatefulWidget {
  final List<ReservationStatus> status;

  const ReservationList({super.key, required this.status});

  @override
  ConsumerState<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends ConsumerState<ReservationList> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reservationsResult =
          await ref.read(getRestaurantReservationsProvider(widget.status).future);
      debugPrint('Anjing: $reservationsResult');
      setState(() {
        _reservations = List<Reservation>.from(reservationsResult);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _addNewReservation(Reservation reservation) {
    if (widget.status.contains(reservation.reservationStatus)) {
      final exists =
          _reservations.any((existing) => existing.reservationId == reservation.reservationId);

      if (!exists) {
        setState(() {
          _reservations.insert(0, reservation);
        });
      }
    }
  }

  void _handleReservationChanges(Reservation reservation) {
    final index =
        _reservations.indexWhere((existing) => existing.reservationId == reservation.reservationId);

    if (index >= 0) {
      if (!widget.status.contains(reservation.reservationStatus)) {
        setState(() {
          _reservations.removeAt(index);
        });
      } else {
        setState(() {
          _reservations[index] = reservation;
        });
      }
    } else if (widget.status.contains(reservation.reservationStatus)) {
      _addNewReservation(reservation);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(newReservationNotificationProvider, (previous, next) {
      if (next != null && widget.status.contains(next.reservationStatus)) {
        _addNewReservation(next);
      }
    });

    ref.listen(reservationChangesNotificationProvider, (previous, next) {
      if (next != null) {
        _handleReservationChanges(next);
      }
    });

    ref.listen(getRestaurantReservationsProvider(widget.status), (previous, next) {
      _loadReservations();
    });

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading reservations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppPallete.neutralColor.shade500,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _loadReservations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No reservations yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppPallete.neutralColor.shade500,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReservations,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _reservations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          return ReservationCard(
            reservation: reservation,
            statusFilter: widget.status,
          );
        },
      ),
    );
  }
}
