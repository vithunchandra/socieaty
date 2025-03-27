import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/restaurant/provider/get_restaurant_reservations_provider.dart';
import 'package:socieaty/features/reservation/restaurant/viewmodel/update_reservation_status_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';

class ReservationDetailsSheet extends ConsumerStatefulWidget {
  final Reservation reservation;
  final ScrollController scrollController;
  final List<ReservationStatus> statusFilter;

  const ReservationDetailsSheet(
      {super.key,
      required this.reservation,
      required this.scrollController,
      required this.statusFilter});

  @override
  ConsumerState<ReservationDetailsSheet> createState() => _ReservationDetailsSheetState();
}

class _ReservationDetailsSheetState extends ConsumerState<ReservationDetailsSheet> {
  void _updateReservationStatus(ReservationStatus newStatus) {
    ref
        .read(updateReservationStatusViewModelProvider(widget.reservation.reservationId).notifier)
        .updateReservationStatus(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      ReservationStatus.pending: Colors.orange,
      ReservationStatus.confirmed: Colors.blue,
      ReservationStatus.cancelled: Colors.red,
      ReservationStatus.completed: Colors.green,
    };

    final statusNames = {
      ReservationStatus.pending: 'MENUNGGU',
      ReservationStatus.confirmed: 'DIKONFIRMASI',
      ReservationStatus.cancelled: 'DIBATALKAN',
      ReservationStatus.completed: 'SELESAI',
    };

    ref.listen(updateReservationStatusViewModelProvider(widget.reservation.reservationId),
        (previous, next) {
      switch (next.updatedReservation) {
        case SuccessState<Reservation>(data: final data):
          ref.invalidate(getRestaurantReservationsProvider(widget.statusFilter));
          showSnackbar(
            context,
            'Reservasi berhasil ${data.reservationStatus.updatedStatusName()}',
            state: SnackbarState.success,
          );
          context.pop();
        case ErrorState(message: var message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState<Reservation>():
        case IdleState():
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reservasi #${widget.reservation.reservationId.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColors[widget.reservation.reservationStatus]?.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusNames[widget.reservation.reservationStatus] ?? '',
                        style: TextStyle(
                          color: statusColors[widget.reservation.reservationStatus],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Informasi Pelanggan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ProfilePictureWidget(
                    radius: 20,
                    user: UserConverter.customerToUser(widget.reservation.customer),
                  ),
                  title: Text(
                    widget.reservation.customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      context.push('/track-reservation/message', extra: widget.reservation);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppPallete.primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat, size: 16, color: AppPallete.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Chat',
                            style: TextStyle(
                              color: AppPallete.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 32),
                const Text(
                  'Detail Reservasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  icon: Icons.calendar_today,
                  title: 'Tanggal',
                  value: _formatDate(widget.reservation.reservationTime),
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  icon: Icons.access_time,
                  title: 'Waktu',
                  value: _formatTime(widget.reservation.reservationTime),
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  icon: Icons.people_outline,
                  title: 'Jumlah Orang',
                  value: '${widget.reservation.peopleSize} orang',
                ),
                if (widget.reservation.menuItems.isNotEmpty) ...[
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Menu Pre-order',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.reservation.menuItems.length} item',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...widget.reservation.menuItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.menu.pictureUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menu.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${item.price.toIDRFormat()} x ${item.quantity}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Rp ${item.totalPrice.toIDRFormat()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                if (widget.reservation.note.isNotEmpty) ...[
                  const Divider(height: 32),
                  const Text(
                    'Catatan Tambahan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_alt, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.reservation.note,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(height: 32),
                const Text(
                  'Detail Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('Rp ${widget.reservation.grossAmount.toIDRFormat()}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Biaya Layanan'),
                    Text('Rp ${widget.reservation.serviceFee.toIDRFormat()}'),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${widget.reservation.grossAmount.toIDRFormat()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (widget.reservation.reservationStatus == ReservationStatus.pending)
            PendingReservationActions(
              reservation: widget.reservation,
              onUpdateReservationStatus: _updateReservationStatus,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPallete.primaryColor.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppPallete.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('EEEE, d MMMM yyyy');
    return formatter.format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }
}

class PendingReservationActions extends ConsumerStatefulWidget {
  final Reservation reservation;
  final void Function(ReservationStatus) onUpdateReservationStatus;
  const PendingReservationActions({
    super.key,
    required this.reservation,
    required this.onUpdateReservationStatus,
  });

  @override
  ConsumerState<PendingReservationActions> createState() => _PendingReservationActionsState();
}

class _PendingReservationActionsState extends ConsumerState<PendingReservationActions> {
  ReservationStatus? _lastUpdatedStatus;

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref
        .watch(updateReservationStatusViewModelProvider(widget.reservation.reservationId))
        .updatedReservation is LoadingState;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _lastUpdatedStatus = ReservationStatus.cancelled;
                      });
                      widget.onUpdateReservationStatus(ReservationStatus.cancelled);
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading && _lastUpdatedStatus == ReservationStatus.cancelled
                  ? const LoadingIndicatorWidget(size: 16)
                  : const Text('Tolak Reservasi'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _lastUpdatedStatus = ReservationStatus.confirmed;
                      });
                      widget.onUpdateReservationStatus(ReservationStatus.confirmed);
                    },
              child: isLoading && _lastUpdatedStatus == ReservationStatus.confirmed
                  ? const LoadingIndicatorWidget(size: 16)
                  : const Text('Terima Reservasi'),
            ),
          ),
        ],
      ),
    );
  }
}
