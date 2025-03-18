import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/food-order/customer/provider/get_all_food_order_transactions_provider.dart';
import 'package:socieaty/features/food-order/customer/widgets/order_card.dart';

class OrderList extends ConsumerWidget {
  final List<FoodOrderStatus> statuses;
  final bool isActiveTab;
  final Function() onRefresh;

  const OrderList({
    super.key,
    required this.statuses,
    required this.isActiveTab,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(getAllFoodOrderTransactionsProvider(statuses));

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
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
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OrderCard(
                  order: orders[index],
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
              isActiveTab ? Icons.local_dining_outlined : Icons.receipt_long_outlined,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              isActiveTab ? 'Pesanan Aktif Kosong' : 'Riwayat Pesanan Kosong',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isActiveTab
                  ? 'Pesanan aktif Anda akan muncul di sini'
                  : 'Riwayat pesanan Anda akan muncul di sini',
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
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppPallete.primaryColor),
          ),
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
