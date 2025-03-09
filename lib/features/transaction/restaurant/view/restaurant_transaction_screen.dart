import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/restaurant/provider/new_order_notification_provider.dart';
import 'package:socieaty/features/transaction/restaurant/provider/get_restaurant_food_transaction_provider.dart';
import 'package:socieaty/features/transaction/restaurant/widgets/order_details_sheet.dart';
import 'package:socieaty/features/transaction/restaurant/widgets/order_list.dart';

class RestaurantTransactionScreen extends ConsumerStatefulWidget {
  final FoodOrderTransaction? order;

  const RestaurantTransactionScreen({super.key, this.order});

  @override
  ConsumerState<RestaurantTransactionScreen> createState() => _RestaurantTransactionScreenState();
}

class _RestaurantTransactionScreenState extends ConsumerState<RestaurantTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // If we received an orderId from notification, show that order details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.order != null) {
        _showHighlightedOrder(widget.order!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Show the order details for a highlighted order (from notifications)
  void _showHighlightedOrder(FoodOrderTransaction order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => OrderDetailsSheet(
          order: order,
          statusFilter: [TransactionStatus.pending],
          scrollController: scrollController,
        ),
      ),
    );
  }

  // Navigate to the history screen
  void _navigateToHistory() {
    context.push('/restaurant/transaksi/history');
  }

  @override
  Widget build(BuildContext context) {
    // Listen for new order notifications
    ref.listen(newOrderNotificationProvider, (previous, next) {
      if (next != null) {
        // New order received, refresh the pending orders list
        ref.invalidate(getRestaurantFoodTransactionProvider([TransactionStatus.pending]));

        // Show snackbar notification for new order
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New order received from ${next.customer.name}'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                _showHighlightedOrder(next);
              },
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Order notification has been processed, reset it
        ref.read(newOrderNotificationProvider.notifier).resetNotification();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Transaksi',
            onPressed: _navigateToHistory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(178), // 70% of 255
          tabs: const [
            Tab(text: 'Baru'),
            Tab(text: 'Berlangsung'),
            Tab(text: 'Siap'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrderList(
            statusFilter: [TransactionStatus.pending],
          ),
          OrderList(
            statusFilter: [TransactionStatus.preparing],
          ),
          OrderList(
            statusFilter: [TransactionStatus.ready],
          ),
        ],
      ),
    );
  }
}
