import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final bool isActive;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = reservation.reservationStatus.getStatusColor();
    final textTheme = Theme.of(context).textTheme;
    final formatter = DateFormat('dd MMM yyyy • HH:mm');

    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: AppPallete.neutralColor.withAlpha(128),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/track-reservation', extra: reservation.reservationId);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isActive) _buildActiveBadge(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      reservation.restaurant.restaurantData.restaurantBannerUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: AppPallete.neutralColor.shade200,
                        child: Icon(Icons.restaurant, color: AppPallete.neutralColor.shade500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.restaurant.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                            fontSize: isActive ? 17 : 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (!isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  reservation.reservationStatus.getStatusName(),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (!isActive) const SizedBox(width: 6),
                            Text(
                              isActive
                                  ? 'Reservasi #${_getReservationIdSubstring()}'
                                  : '• Reservasi #${_getReservationIdSubstring()}',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppPallete.neutralColor.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: AppPallete.neutralColor.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatter.format(reservation.reservationTime),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppPallete.neutralColor.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: AppPallete.neutralColor.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reservation.peopleSize} orang',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppPallete.neutralColor.shade800,
                        ),
                      ),
                    ],
                  ),
                  if (reservation.note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: AppPallete.neutralColor.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reservation.note,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppPallete.neutralColor.shade800,
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
    );
  }

  Widget _buildActiveBadge(BuildContext context) {
    String statusText;
    Color bgColor;

    switch (reservation.reservationStatus) {
      case ReservationStatus.pending:
        statusText = 'Menunggu Konfirmasi';
        bgColor = Colors.amber.shade700;
        break;
      case ReservationStatus.confirmed:
        statusText = 'Reservasi Dikonfirmasi';
        bgColor = Colors.blue.shade700;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          statusText,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  String _getReservationIdSubstring() {
    if (reservation.reservationId.isEmpty) {
      return '';
    }
    return reservation.reservationId.length >= 4
        ? reservation.reservationId.substring(0, 4)
        : reservation.reservationId;
  }
}
