import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/provider/get_reservations_provider.dart';
import 'package:socieaty/features/reservation/repository/request/get_reservations_query.dart';
import 'package:socieaty/features/reservation/restaurant/provider/new_reservation_notification_provider.dart';
import 'package:socieaty/features/reservation/restaurant/provider/reservation_changes_notification_provider.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_card.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class ReservationList extends ConsumerStatefulWidget {
  final GetReservationsQuery query;

  const ReservationList({super.key, required this.query});

  @override
  ConsumerState<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends ConsumerState<ReservationList> {
  @override
  Widget build(BuildContext context) {
    ref.listen(newReservationNotificationProvider, (previous, next) {
      if (next != null && widget.query.reservationStatus.contains(next.reservationStatus)) {
        ref.invalidate(getReservationsProvider(widget.query));
      }
    });

    ref.listen(reservationChangesNotificationProvider, (previous, next) {
      if (next != null) {
        ref.invalidate(getReservationsProvider(widget.query));
      }
    });

    return ref.watch(getReservationsProvider(widget.query)).when(data: (data) {
      if (data.reservations.isEmpty) {
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
        onRefresh: () => ref.refresh(getReservationsProvider(widget.query).future),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.reservations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final reservation = data.reservations[index];
            return ReservationCard(
              reservation: reservation,
              onUpdatedReservation: (reservation) {
                ref.invalidate(getReservationsProvider(widget.query));
              },
            );
          },
        ),
      );
    }, error: (error, stackTrace) {
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
              onPressed: () => ref.invalidate(getReservationsProvider(widget.query)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }, loading: () {
      return const LoadingIndicatorWidget(size: 36);
    });
  }
}
