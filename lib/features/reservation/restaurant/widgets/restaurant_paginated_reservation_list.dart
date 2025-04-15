import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/provider/get_reservations_provider.dart';
import 'package:socieaty/features/reservation/provider/paginate_reservations_provider.dart';
import 'package:socieaty/features/reservation/repository/request/paginate_reservations_query.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_card.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class RestaurantPaginatedReservationList extends ConsumerStatefulWidget {
  final List<ReservationStatus> status;
  final int pageSize;

  const RestaurantPaginatedReservationList({
    super.key,
    required this.status,
    this.pageSize = 10,
  });

  @override
  ConsumerState<RestaurantPaginatedReservationList> createState() =>
      _RestaurantPaginatedReservationListState();
}

class _RestaurantPaginatedReservationListState
    extends ConsumerState<RestaurantPaginatedReservationList> {
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
      final user = ref.watch(authLocalRepositoryProvider).getUserData();
      final query = PaginateReservationsQuery(
        restaurantId: user?.restaurantData?.id,
        reservationStatus: widget.status,
        paginationQuery: PaginationQuery(page: pageKey, pageSize: widget.pageSize),
      );

      final result = await ref.read(paginateReservationsProvider(query).future);

      final reservations = result.items;
      final isLastPage = !result.pagination.hasNext;

      if (isLastPage) {
        _pagingController.appendLastPage(reservations);
      } else {
        final nextPageKey = result.pagination.nextPage;
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
      onRefresh: () {
        _pagingController.refresh();
        return Future.value();
      },
      child: PagedListView.separated(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        builderDelegate: PagedChildBuilderDelegate<Reservation>(
          itemBuilder: (context, reservation, index) {
            return ReservationCard(
              reservation: reservation,
            );
          },
          firstPageProgressIndicatorBuilder: (_) => const LoadingIndicatorWidget(size: 36),
          newPageProgressIndicatorBuilder: (_) => const LoadingIndicatorWidget(size: 24),
          firstPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
            error: _pagingController.error.toString(),
            title: 'Reservations',
            onPressed: _pagingController.refresh,
          ),
          newPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
            error: _pagingController.error.toString(),
            title: 'Reservations',
            onPressed: _pagingController.retryLastFailedRequest,
          ),
          noItemsFoundIndicatorBuilder: (context) => Center(
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
          ),
        ),
      ),
    );
  }
}
