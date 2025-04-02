import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/customer/provider/get_customer_reservations_provider.dart';
import 'package:socieaty/features/reservation/customer/viewstate/get_reservations_history_query_state.dart';
import 'package:socieaty/features/reservation/customer/widgets/reservation_card.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class ReservationList extends ConsumerWidget {
  final GetReservationsHistoryQueryState queryState;
  final bool isActiveTab;
  final Function() onRefresh;

  const ReservationList({
    super.key,
    required this.queryState,
    required this.isActiveTab,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(getCustomerReservationsProvider(queryState));

    return reservationsAsync.when(
      data: (reservations) {
        if (reservations.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          color: AppPallete.primaryColor,
          onRefresh: () async {
            onRefresh();
          },
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ReservationCard(
                  reservation: reservations[index],
                  isActive: isActiveTab,
                ),
              );
            },
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActiveTab ? Icons.event_available_outlined : Icons.history_outlined,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              isActiveTab ? 'Reservasi Aktif Kosong' : 'Riwayat Reservasi Kosong',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isActiveTab
                  ? 'Reservasi aktif Anda akan muncul di sini'
                  : 'Riwayat reservasi Anda akan muncul di sini',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppPallete.neutralColor.shade600,
                height: 1.3,
              ),
            ),
            if (isActiveTab) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(
                  Icons.restaurant,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text('Buat Reservasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicatorWidget(size: 20),
          const SizedBox(height: 16),
          Text(
            'Loading your reservations...',
            style: TextStyle(
              color: AppPallete.neutralColor.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: AppPallete.neutralColor.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "Couldn't load your reservations",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
