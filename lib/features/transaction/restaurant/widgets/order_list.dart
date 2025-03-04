import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/restaurant/provider/get_restaurant_food_transaction_provider.dart';
import 'package:socieaty/features/transaction/restaurant/widgets/order_card.dart';

class OrderList extends ConsumerStatefulWidget {
  final TransactionStatus statusFilter;
  final Function(FoodOrderTransaction)? onViewOrderDetails;

  const OrderList({
    super.key,
    required this.statusFilter,
    this.onViewOrderDetails,
  });

  @override
  ConsumerState<OrderList> createState() => _OrderListState();
}

class _OrderListState extends ConsumerState<OrderList> {

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(getRestaurantFoodTransactionProvider(widget.statusFilter));

    return orders.when(
      data: (data) {
        final filteredOrders = data.where((order) => order.status == widget.statusFilter).toList();

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyStateIcon(widget.statusFilter),
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyStateTitle(widget.statusFilter),
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyStateMessage(widget.statusFilter),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredOrders.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return OrderCard(
              order: order,
              onViewDetails: widget.onViewOrderDetails,
            );
          },
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak dapat memuat pesanan. Silakan coba lagi nanti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(getRestaurantFoodTransactionProvider(widget.statusFilter)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  IconData _getEmptyStateIcon(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return Icons.task_alt;
    } else if (status == TransactionStatus.rejected) {
      return Icons.cancel;
    } else {
      return Icons.receipt_long;
    }
  }

  String _getEmptyStateTitle(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return 'Tidak Ada Pesanan Selesai';
    } else if (status == TransactionStatus.ready || status == TransactionStatus.preparing) {
      return 'Tidak Ada Pesanan Berlangsung';
    } else {
      return 'Tidak Ada Pesanan Baru';
    }
  }

  String _getEmptyStateMessage(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return 'Pesanan yang telah selesai akan muncul di sini';
    } else if (status == TransactionStatus.ready || status == TransactionStatus.preparing) {
      return 'Pesanan yang sedang diproses akan muncul di sini';
    } else {
      return 'Pesanan baru yang menunggu konfirmasi akan muncul di sini';
    }
  }
}
