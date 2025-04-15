import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food-order/customer/widgets/order_card.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/provider/paginate_food_orders_provider.dart';
import 'package:socieaty/features/food-order/repository/request/paginate_orders_request_query.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class CustomerPaginatedOrderList extends ConsumerStatefulWidget {
  final List<FoodOrderStatus> statuses;
  final bool isActiveTab;
  final Function() onRefresh;
  final int pageSize;

  const CustomerPaginatedOrderList({
    super.key,
    required this.statuses,
    required this.isActiveTab,
    required this.onRefresh,
    this.pageSize = 10,
  });

  @override
  ConsumerState<CustomerPaginatedOrderList> createState() => _CustomerPaginatedOrderListState();
}

class _CustomerPaginatedOrderListState extends ConsumerState<CustomerPaginatedOrderList> {
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
      final customer = UserConverter.userToCustomer(user!);
      final query = PaginateOrdersRequestQuery(
        customerId: customer.customerData.id,
        status: widget.statuses,
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
      color: AppPallete.primaryColor,
      onRefresh: () async {
        widget.onRefresh();
        _pagingController.refresh();
        return Future.value();
      },
      child: PagedListView<int, FoodOrderTransaction>(
        pagingController: _pagingController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        builderDelegate: PagedChildBuilderDelegate<FoodOrderTransaction>(
          itemBuilder: (context, order, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OrderCard(
                order: order,
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
                  'Failed to load more orders',
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
              widget.isActiveTab ? Icons.local_dining_outlined : Icons.receipt_long_outlined,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isActiveTab ? 'Pesanan Aktif Kosong' : 'Riwayat Pesanan Kosong',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.isActiveTab
                  ? 'Pesanan aktif Anda akan muncul di sini'
                  : 'Riwayat pesanan Anda akan muncul di sini',
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
                  Icons.restaurant_menu,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text('Pesan Makanan'),
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
          const LoadingIndicatorWidget(size: 36),
          const SizedBox(height: 16),
          Text(
            'Loading your orders...',
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
              "Couldn't load your orders",
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
