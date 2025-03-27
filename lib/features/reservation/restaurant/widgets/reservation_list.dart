import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/restaurant/provider/get_restaurant_reservations_provider.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_card.dart';

class ReservationList extends ConsumerWidget {
  final List<ReservationStatus> status;

  const ReservationList({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(getRestaurantReservationsProvider(status));

    return reservationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
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
              onPressed: () => ref.refresh(getRestaurantReservationsProvider(status)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (reservations) {
        if (reservations.isEmpty) {
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

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            return ReservationCard(
              reservation: reservation,
              statusFilter: status,
            );
          },
        );
      },
    );
  }
}
