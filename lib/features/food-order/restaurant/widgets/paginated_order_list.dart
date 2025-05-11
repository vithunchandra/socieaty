import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/provider/paginate_food_orders_provider.dart';
import 'package:socieaty/features/food-order/repository/request/paginate_orders_request_query.dart';
import 'package:socieaty/features/food-order/restaurant/widgets/order_card.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class PaginatedOrderList extends ConsumerStatefulWidget {
  final List<FoodOrderStatus> statusFilter;
  final int pageSize;
  final Function(FoodOrderTransaction)? onViewOrderDetails;

  const PaginatedOrderList({
    super.key,
    required this.statusFilter,
    this.pageSize = 10,
    this.onViewOrderDetails,
  });

  @override
  ConsumerState<PaginatedOrderList> createState() => _PaginatedOrderListState();
}

class _PaginatedOrderListState extends ConsumerState<PaginatedOrderList> {
  late final PagingController<int, FoodOrderTransaction> _pagingController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, FoodOrderTransaction>(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchOrders(pageKey);
    });
  }

  Future<void> _fetchOrders(int pageKey) async {
    if (!mounted || _isDisposed) return;

    try {
      final user = ref.watch(authLocalRepositoryProvider).getUserData();
      final restaurant = UserConverter.userToRestaurant(user!);
      final query = PaginateOrdersRequestQuery(
        restaurantId: restaurant.restaurantData.id,
        status: widget.statusFilter,
        paginationQuery: PaginationQuery(page: pageKey, pageSize: widget.pageSize),
      );

      final result = await ref.read(paginateFoodOrdersProvider(query: query).future);

      final orders = result.items;
      final isLastPage = orders.length < widget.pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(orders);
      } else {
        final nextPageKey = pageKey + widget.pageSize;
        _pagingController.appendPage(orders, nextPageKey);
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
        builderDelegate: PagedChildBuilderDelegate<FoodOrderTransaction>(
          itemBuilder: (context, order, index) {
            return OrderCard(
              statusFilter: widget.statusFilter,
              order: order,
              onViewDetails: widget.onViewOrderDetails,
            );
          },
          firstPageProgressIndicatorBuilder: (_) => const LoadingIndicatorWidget(size: 36),
          newPageProgressIndicatorBuilder: (_) => const LoadingIndicatorWidget(size: 24),
          firstPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
            error: _pagingController.error.toString(),
            title: 'Pesanan',
            onPressed: _pagingController.refresh,
          ),
          newPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
            error: _pagingController.error.toString(),
            title: 'Pesanan',
            onPressed: _pagingController.retryLastFailedRequest,
          ),
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyStateIcon(widget.statusFilter.first),
                  size: 64,
                  color: AppPallete.neutralColor.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyStateTitle(widget.statusFilter.first),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPallete.neutralColor.shade500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyStateMessage(widget.statusFilter.first),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
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

  IconData _getEmptyStateIcon(FoodOrderStatus status) {
    if (status == FoodOrderStatus.completed) {
      return Icons.task_alt;
    } else if (status == FoodOrderStatus.rejected) {
      return Icons.cancel;
    } else if (status == FoodOrderStatus.ready) {
      return Icons.delivery_dining;
    } else if (status == FoodOrderStatus.preparing) {
      return Icons.restaurant;
    } else {
      return Icons.receipt_long;
    }
  }

  String _getEmptyStateTitle(FoodOrderStatus status) {
    if (status == FoodOrderStatus.completed) {
      return 'Tidak Ada Pesanan Selesai';
    } else if (status == FoodOrderStatus.rejected) {
      return 'Tidak Ada Pesanan Batal';
    } else if (status == FoodOrderStatus.ready) {
      return 'Tidak Ada Pesanan Siap';
    } else if (status == FoodOrderStatus.preparing) {
      return 'Tidak Ada Pesanan Proses';
    } else {
      return 'Tidak Ada Pesanan Baru';
    }
  }

  String _getEmptyStateMessage(FoodOrderStatus status) {
    if (status == FoodOrderStatus.completed) {
      return 'Pesanan yang telah selesai akan muncul di sini';
    } else if (status == FoodOrderStatus.rejected) {
      return 'Pesanan yang dibatalkan akan muncul di sini';
    } else if (status == FoodOrderStatus.ready) {
      return 'Pesanan yang siap diambil akan muncul di sini';
    } else if (status == FoodOrderStatus.preparing) {
      return 'Pesanan yang sedang diproses akan muncul di sini';
    } else {
      return 'Pesanan baru akan muncul di sini';
    }
  }
}
