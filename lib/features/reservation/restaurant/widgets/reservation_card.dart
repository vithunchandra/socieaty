import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/restaurant/provider/get_restaurant_reservations_provider.dart';
import 'package:socieaty/features/reservation/restaurant/viewmodel/restaurant_reservation_view_model.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_details_sheet.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/status_chip.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class ReservationCard extends ConsumerStatefulWidget {
  final Reservation reservation;
  final List<ReservationStatus> statusFilter;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.statusFilter,
  });

  @override
  ConsumerState<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends ConsumerState<ReservationCard> {
  ReservationStatus? _lastUpdatedStatus;
  late Reservation _reservation;
  late List<ReservationStatus> _statusFilter;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
    _statusFilter = widget.statusFilter;
  }

  @override
  void didUpdateWidget(ReservationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reservation != widget.reservation) {
      _reservation = widget.reservation;
    }
    if (oldWidget.statusFilter != widget.statusFilter) {
      _statusFilter = widget.statusFilter;
    }
  }

  void _showReservationDetails(BuildContext context, Reservation reservation) {
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
        builder: (_, scrollController) {
          return ReservationDetailsSheet(
            reservation: reservation,
            scrollController: scrollController,
            statusFilter: _statusFilter,
          );
        },
      ),
    );
  }

  void _updateReservationStatus(ReservationStatus newStatus) {
    setState(() {
      _lastUpdatedStatus = newStatus;
    });
    ref
        .read(restaurantReservationViewModelProvider(_reservation.reservationId).notifier)
        .updateReservationStatus(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref
        .watch(restaurantReservationViewModelProvider(_reservation.reservationId))
        .updatedReservation is LoadingState;

    ref.listen(restaurantReservationViewModelProvider(_reservation.reservationId),
        (previous, next) {
      switch (next.updatedReservation) {
        case SuccessState<Reservation>():
          ref.invalidate(getRestaurantReservationsProvider(_statusFilter));
        case ErrorState(message: var message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState<Reservation>():
        case IdleState():
      }
    });

    return GestureDetector(
      onTap: () => _showReservationDetails(context, _reservation),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPallete.primaryColor.withAlpha(10),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  ProfilePictureWidget(
                    user: UserConverter.customerToUser(_reservation.customer),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _reservation.customer.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          _reservation.customer.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppPallete.neutralColor.shade500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  getStatusChip(_reservation.reservationStatus),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          context,
                          Icons.calendar_today,
                          'Date',
                          _formatDateShort(_reservation.reservationTime),
                          AppPallete.primaryColor.withAlpha(25),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoTile(
                          context,
                          Icons.access_time,
                          'Time',
                          _formatTimeShort(_reservation.reservationTime),
                          AppPallete.infoColor.withAlpha(25),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoTile(
                          context,
                          Icons.people,
                          'People',
                          '${_reservation.peopleSize} persons',
                          AppPallete.successColor.withAlpha(25),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_reservation.note.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppPallete.neutralColor.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 16,
                            color: AppPallete.neutralColor.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _reservation.note,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppPallete.neutralColor.shade700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_reservation.reservationStatus == ReservationStatus.pending)
                    PendingReservationCardActions(
                      reservation: _reservation,
                      isLoading: isLoading,
                      lastUpdatedStatus: _lastUpdatedStatus,
                      onUpdateStatus: (status) {
                        setState(() {
                          _lastUpdatedStatus = status;
                        });
                        _updateReservationStatus(status);
                      },
                    ),
                  if (_reservation.reservationStatus == ReservationStatus.confirmed)
                    ConfirmedReservationCardActions(
                      reservation: _reservation,
                      isLoading: isLoading,
                      lastUpdatedStatus: _lastUpdatedStatus,
                      onUpdateStatus: (status) {
                        setState(() {
                          _lastUpdatedStatus = status;
                        });
                        _updateReservationStatus(status);
                      },
                    ),
                  if (_reservation.reservationStatus == ReservationStatus.dining)
                    DiningReservationCardActions(
                      reservation: _reservation,
                      isLoading: isLoading,
                      lastUpdatedStatus: _lastUpdatedStatus,
                      onUpdateStatus: (status) {
                        setState(() {
                          _lastUpdatedStatus = status;
                        });
                        _updateReservationStatus(status);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color bgColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: bgColor == AppPallete.primaryColor.withAlpha(25)
                ? AppPallete.primaryColor
                : bgColor == AppPallete.infoColor.withAlpha(25)
                    ? AppPallete.infoColor
                    : AppPallete.successColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppPallete.neutralColor.shade500,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDateShort(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return 'Today';
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      final formatter = DateFormat('MMM d, yyyy');
      return formatter.format(dateTime);
    }
  }

  String _formatTimeShort(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }
}

class PendingReservationCardActions extends StatelessWidget {
  final Reservation reservation;
  final bool isLoading;
  final ReservationStatus? lastUpdatedStatus;
  final Function(ReservationStatus) onUpdateStatus;

  const PendingReservationCardActions({
    super.key,
    required this.reservation,
    required this.isLoading,
    required this.lastUpdatedStatus,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => onUpdateStatus(ReservationStatus.rejected),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: AppPallete.errorColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: isLoading && lastUpdatedStatus == ReservationStatus.rejected
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppPallete.errorColor,
                    ),
                  )
                : Text(
                    'Decline',
                    style: TextStyle(
                      color: AppPallete.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : () => onUpdateStatus(ReservationStatus.confirmed),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: AppPallete.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: isLoading && lastUpdatedStatus == ReservationStatus.confirmed
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class ConfirmedReservationCardActions extends StatelessWidget {
  final Reservation reservation;
  final bool isLoading;
  final ReservationStatus? lastUpdatedStatus;
  final Function(ReservationStatus) onUpdateStatus;

  const ConfirmedReservationCardActions({
    super.key,
    required this.reservation,
    required this.isLoading,
    required this.lastUpdatedStatus,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Empty function for "See Schedule"
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('See Schedule'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPallete.primaryColor,
              side: BorderSide(color: AppPallete.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => onUpdateStatus(ReservationStatus.dining),
            icon: isLoading && lastUpdatedStatus == ReservationStatus.dining
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.restaurant,
                    size: 16,
                    color: Colors.white,
                  ),
            label: const Text(
              'Layani',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class DiningReservationCardActions extends StatelessWidget {
  final Reservation reservation;
  final bool isLoading;
  final ReservationStatus? lastUpdatedStatus;
  final Function(ReservationStatus) onUpdateStatus;

  const DiningReservationCardActions({
    super.key,
    required this.reservation,
    required this.isLoading,
    required this.lastUpdatedStatus,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Empty function for "Add order"
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Add Order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPallete.primaryColor,
              side: BorderSide(color: AppPallete.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => onUpdateStatus(ReservationStatus.completed),
            icon: isLoading && lastUpdatedStatus == ReservationStatus.completed
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.white,
                  ),
            label: const Text(
              'Complete',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
