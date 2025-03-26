import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/restaurant/provider/get_restaurant_food_order_provider.dart';
import 'package:socieaty/features/food-order/restaurant/provider/new_order_notification_provider.dart';
import 'package:socieaty/features/food-order/restaurant/widgets/order_card.dart';

class OrderList extends ConsumerStatefulWidget {
  final List<FoodOrderStatus> statusFilter;
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
  bool _isLoading = true;
  String? _errorMessage;

  List<FoodOrderTransaction> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();

    ref.listenManual(getRestaurantFoodOrderProvider(widget.statusFilter), (previous, next) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ordersResult =
          await ref.read(getRestaurantFoodOrderProvider(widget.statusFilter).future);

      setState(() {
        _orders = List<FoodOrderTransaction>.from(ordersResult);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addNewOrder(FoodOrderTransaction order) {
    if (widget.statusFilter.contains(order.foodOrderStatus)) {
      final exists = _orders.any((existing) => existing.orderId == order.orderId);

      if (!exists) {
        setState(() {
          _orders.insert(0, order);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(newOrderNotificationProvider, (previous, next) {
      if (next != null && widget.statusFilter.contains(next.foodOrderStatus)) {
        _addNewOrder(next);
      }
    });

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
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
            const Text(
              'Gagal Memuat Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(widget.statusFilter.first),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(widget.statusFilter.first),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(widget.statusFilter.first),
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

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        itemCount: _orders.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return OrderCard(
            statusFilter: widget.statusFilter,
            order: order,
            onViewDetails: widget.onViewOrderDetails,
          );
        },
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
