import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/restaurant/provider/get_restaurant_food_transaction_provider.dart';
import 'package:socieaty/features/transaction/restaurant/provider/new_order_notification_provider.dart';
import 'package:socieaty/features/transaction/restaurant/widgets/order_card.dart';

class OrderList extends ConsumerStatefulWidget {
  final List<TransactionStatus> statusFilter;
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
  // Track loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  // Our list of orders for this tab
  List<FoodOrderTransaction> _orders = [];

  @override
  void initState() {
    super.initState();
    // Load orders initially
    _loadOrders();

    // Listen for provider invalidations (for status changes)
    ref.listenManual(getRestaurantFoodTransactionProvider(widget.statusFilter), (previous, next) {
      // Reload when the provider is invalidated (from status changes)
      _loadOrders();
    });
  }

  // Load orders from the API
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get orders from the provider
      final ordersResult =
          await ref.read(getRestaurantFoodTransactionProvider(widget.statusFilter).future);

      setState(() {
        // Create a new List that we can modify (not unmodifiable)
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

  // Add a new order to the list if it matches our status filter
  void _addNewOrder(FoodOrderTransaction order) {
    if (widget.statusFilter.contains(order.status)) {
      // Check if order already exists
      final exists = _orders.any((existing) => existing.id == order.id);

      if (!exists) {
        setState(() {
          // Add to beginning of list
          _orders.insert(0, order);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for new order notifications that match this list's status filter
    ref.listen(newOrderNotificationProvider, (previous, next) {
      if (next != null && widget.statusFilter.contains(next.status)) {
        // Add the new order to our local list
        _addNewOrder(next);

        // Add a subtle animation or highlight to indicate a new order
        if (mounted && context.mounted) {
          // This could be enhanced with a more sophisticated animation
          // or by scrolling to the new item
        }
      }
    });

    // Show a loading indicator while loading
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show an error message if there was an error
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
              'Error Loading Orders',
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
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show an empty state if there are no orders
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

    // Show the list of orders with pull-to-refresh
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

  IconData _getEmptyStateIcon(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return Icons.task_alt;
    } else if (status == TransactionStatus.rejected) {
      return Icons.cancel;
    } else if (status == TransactionStatus.ready) {
      return Icons.delivery_dining;
    } else if (status == TransactionStatus.preparing) {
      return Icons.restaurant;
    } else {
      return Icons.receipt_long;
    }
  }

  String _getEmptyStateTitle(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return 'Tidak Ada Pesanan Selesai';
    } else if (status == TransactionStatus.rejected) {
      return 'Tidak Ada Pesanan Ditolak';
    } else if (status == TransactionStatus.ready) {
      return 'Tidak Ada Pesanan Siap';
    } else if (status == TransactionStatus.preparing) {
      return 'Tidak Ada Pesanan Berlangsung';
    } else {
      return 'Tidak Ada Pesanan Baru';
    }
  }

  String _getEmptyStateMessage(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return 'Pesanan yang telah selesai akan muncul di sini';
    } else if (status == TransactionStatus.rejected) {
      return 'Pesanan yang ditolak akan muncul di sini';
    } else if (status == TransactionStatus.ready) {
      return 'Pesanan yang siap diambil akan muncul di sini';
    } else if (status == TransactionStatus.preparing) {
      return 'Pesanan yang sedang diproses akan muncul di sini';
    } else {
      return 'Pesanan baru yang menunggu konfirmasi akan muncul di sini';
    }
  }
}
