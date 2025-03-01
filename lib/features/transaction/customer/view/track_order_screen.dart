import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/features/customer/socket/customer_socket_service.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';

class TrackOrderScreen extends ConsumerStatefulWidget {
  final String orderId;

  const TrackOrderScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  // Store the order data in the widget state
  late CustomerSocketService _socketService;
  FoodOrderTransaction? _orderData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Setup socket listeners after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
  }

  @override
  void dispose() {
    // Clean up listeners on dispose
    _removeSocketListeners();
    super.dispose();
  }

  void _setupSocketListeners() {
    _socketService = ref.read(customerSocketServiceProvider);

    // Ensure socket is connected
    _socketService.initConnection();
    _socketService.trackOrder(widget.orderId);
    _socketService.listenOrderUpdate(_handleOrderUpdate);
  }

  void _removeSocketListeners() {
    _socketService = ref.read(customerSocketServiceProvider);
    _socketService.disconnect();
    _socketService.removeListener('track-order');
  }

  void _handleOrderUpdate(dynamic data) {
    debugPrint('Received order update: $data');

    try {
      final updatedOrder = FoodOrderTransaction.fromJson(data);

      // Only update if this is for our order
      if (updatedOrder.id == widget.orderId) {
        if (mounted) {
          setState(() {
            _orderData = updatedOrder;
            _isLoading = false;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error processing order update: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error processing order data';
          _isLoading = false;
        });
      }
    }
  }

  String _getStatusMessage(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirming:
        return 'Restaurant is confirming your order';
      case TransactionStatus.pending:
        return 'Order is being processed';
      case TransactionStatus.process:
        return 'Your food is being prepared';
      case TransactionStatus.completed:
        return 'Order has been completed';
      case TransactionStatus.cancelled:
        return 'Order was cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${widget.orderId}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to track your order...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error tracking your order: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _setupSocketListeners,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orderData == null) {
      return const Center(
        child: Text('No order data available'),
      );
    }

    return _buildOrderTracking(_orderData!);
  }

  Widget _buildOrderTracking(FoodOrderTransaction order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status Card
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${order.status.toString().split('.').last}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusMessage(order.status),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _getProgressValue(order.status),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),

          // Restaurant Info
          Text(
            'Restaurant',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(order.restaurant.restaurantData.restaurantBannerUrl),
              ),
              title: Text(order.restaurant.name),
              // Show coordinates since address isn't directly available
              subtitle: Text(
                  'Location: (${order.restaurant.restaurantData.location.latitude.toStringAsFixed(2)}, ${order.restaurant.restaurantData.location.longitude.toStringAsFixed(2)})'),
            ),
          ),

          const SizedBox(height: 24),

          // Order Items
          Text(
            'Your Order',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...order.menuItems.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.menu.name),
                  subtitle: Text('${item.quantity}x @ \$${item.price}'),
                  trailing: Text('\$${item.totalPrice}'),
                ),
              )),

          const SizedBox(height: 24),

          // Order Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('\$${order.grossAmount}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service Fee'),
                      Text('\$${order.serviceFee}'),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${order.grossAmount + order.serviceFee}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getProgressValue(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirming:
        return 0.2;
      case TransactionStatus.pending:
        return 0.4;
      case TransactionStatus.process:
        return 0.8;
      case TransactionStatus.completed:
        return 1.0;
      case TransactionStatus.cancelled:
        return 0.0;
    }
  }
}
