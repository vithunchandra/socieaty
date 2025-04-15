import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/customer/widgets/reservation_card.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/provider/paginate_reservations_provider.dart';
import 'package:socieaty/features/reservation/repository/request/paginate_reservations_query.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class CustomerPaginatedReservationList extends ConsumerStatefulWidget {
  final PaginateReservationsQuery query;
  final bool isActiveTab;
  final Function() onRefresh;
  final int pageSize;

  const CustomerPaginatedReservationList({
    super.key,
    required this.query,
    required this.isActiveTab,
    required this.onRefresh,
    this.pageSize = 5,
  });

  @override
  ConsumerState<CustomerPaginatedReservationList> createState() =>
      _CustomerPaginatedReservationListState();
}

class _CustomerPaginatedReservationListState
    extends ConsumerState<CustomerPaginatedReservationList> {
  late final PagingController<int, Reservation> _pagingController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Reservation>(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchReservations(pageKey);
    });
  }

  Future<void> _fetchReservations(int pageKey) async {
    if (!mounted || _isDisposed) return;

    try {
      // Use the provided query but update pagination offset
      final paginationQuery = widget.query.paginationQuery.copyWith(
        page: pageKey,
        pageSize: widget.pageSize,
      );

      final query = widget.query.copyWith(
        paginationQuery: paginationQuery,
      );

      final result = await ref.read(paginateReservationsProvider(query).future);

      final reservations = result.items;
      final isLastPage = reservations.length < widget.pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(reservations);
      } else {
        final nextPageKey = pageKey + widget.pageSize;
        _pagingController.appendPage(reservations, nextPageKey);
      }
    } catch (error) {
      if (!_isDisposed) {
        _pagingController.error = error;
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppPallete.primaryColor,
      onRefresh: () async {
        widget.onRefresh();
        _pagingController.refresh();
        return Future.value();
      },
      child: PagedListView<int, Reservation>(
        pagingController: _pagingController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        builderDelegate: PagedChildBuilderDelegate<Reservation>(
          itemBuilder: (context, reservation, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReservationCard(
                reservation: reservation,
                isActive: widget.isActiveTab,
              ),
            );
          },
          firstPageProgressIndicatorBuilder: (_) => _buildLoadingState(),
          newPageProgressIndicatorBuilder: (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppPallete.primaryColor,
                ),
              ),
            ),
          ),
          firstPageErrorIndicatorBuilder: (context) => _buildErrorState(
            context,
            _pagingController.error,
            () => _pagingController.refresh(),
          ),
          newPageErrorIndicatorBuilder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  'Failed to load more reservations',
                  style: TextStyle(
                    color: AppPallete.neutralColor.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _pagingController.retryLastFailedRequest(),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: AppPallete.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(context),
        ),
      ),
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
              widget.isActiveTab ? Icons.event_available_outlined : Icons.history_outlined,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isActiveTab ? 'Reservasi Aktif Kosong' : 'Riwayat Reservasi Kosong',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.isActiveTab
                  ? 'Reservasi aktif Anda akan muncul di sini'
                  : 'Riwayat reservasi Anda akan muncul di sini',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppPallete.neutralColor.shade600,
                height: 1.3,
              ),
            ),
            if (widget.isActiveTab) ...[
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

  Widget _buildErrorState(BuildContext context, Object? error, VoidCallback onRetry) {
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
                error?.toString() ?? "Unknown error occurred",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
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
