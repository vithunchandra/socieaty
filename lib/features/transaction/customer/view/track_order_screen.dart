import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/color_extension.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/customer/socket/customer_socket_service.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';

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
  late CustomerSocketService _socketService;
  FoodOrderTransaction? _orderData;
  bool _isLoading = true;
  String? _errorMessage;

  // For controlling the scroll and header collapse behavior
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    // Initialize socket service
    _socketService = ref.read(customerSocketServiceProvider);

    // Setup scroll listener to track collapsing state
    _scrollController.addListener(_handleScroll);

    // Setup socket listeners after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
      // _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _removeSocketListeners();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final double offset = _scrollController.offset;
    final threshold = 100.0; // Adjust this value to control when the header collapses
    final isCollapsed = offset > threshold;

    if (isCollapsed != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
    }
  }

  // void _loadInitialData() async {
  //   try {
  //     final repository = ref.read(transactionRepositoryProvider);
  //     final result = await repository.getFoodOrderTransaction(widget.orderId);

  //     switch (result) {
  //       case Success(data: final data):
  //         if (mounted) {
  //           setState(() {
  //             _orderData = data;
  //             _isLoading = false;
  //           });
  //         }
  //       case Error(error: final error):
  //         if (mounted) {
  //           setState(() {
  //             _errorMessage = error.toString();
  //             _isLoading = false;
  //           });
  //         }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _errorMessage = e.toString();
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  void _setupSocketListeners() {
    _socketService.initConnection();
    _socketService.listenOrderUpdate(widget.orderId, _handleOrderUpdate);
    ref.read(transactionRepositoryProvider).trackOrderTransaction(widget.orderId).then((value) {
      switch (value) {
        case Success(data: final data):
          debugPrint('Order tracked: ${data.message}');
        case Error(error: final error):
          debugPrint('Error tracking order: $error');
      }
    });
  }

  void _removeSocketListeners() {
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

  // Navigate to map screen
  void _navigateToMapScreen() {
    // TODO: Implement navigation to map screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map screen will be implemented separately'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getStatusMessage(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Restaurant is reviewing your order';
      case TransactionStatus.rejected:
        return 'Order was rejected';
      case TransactionStatus.preparing:
        return 'Your food is being prepared';
      case TransactionStatus.ready:
        return 'Your order is ready for pickup/delivery';
      case TransactionStatus.completed:
        return 'Order has been completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Track Order #${widget.orderId.substring(0, 8)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null && _orderData == null
              ? _buildErrorView()
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollUpdateNotification) {
                      _handleScroll();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Header (Now Scrollable)
                        _buildFixedHeader(_orderData!),

                        // Content
                        _buildContent(_orderData!),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFixedHeader(FoodOrderTransaction order) {
    return Container(
      color: AppPallete.primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacitySafe(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              order.status.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ETA and Map button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacitySafe(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppPallete.primaryColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Delivery',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        '15-20 minutes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _navigateToMapScreen,
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('View Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(FoodOrderTransaction order) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Status timeline section
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: _buildStatusTimeline(context, order.status),
          ),

          // Status message
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: _buildStatusMessage(order),
          ),

          // Restaurant section
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: _buildRestaurantSection(order),
          ),

          // Order summary section
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
            child: _buildOrderSummary(order),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading order details...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading order: $_errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(FoodOrderTransaction order) {
    // Determine status colors based on current status
    final Color statusColor = _getStatusColor(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacitySafe(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacitySafe(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(order.status),
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusMessage(order.status),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (order.status != TransactionStatus.rejected &&
                    order.status != TransactionStatus.completed)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Please wait while we process your order',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.withOpacitySafe(0.1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection(FoodOrderTransaction order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacitySafe(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              order.restaurant.restaurantData.restaurantBannerUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurant.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppPallete.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Restaurant Location",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppPallete.neutralColor.shade600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withOpacitySafe(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone, size: 16, color: AppPallete.primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Call',
                  style: TextStyle(
                    color: AppPallete.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(FoodOrderTransaction order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacitySafe(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppPallete.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${order.menuItems.length} items',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const DottedDivider(color: AppPallete.neutralColor),
          const SizedBox(height: 12),

          // Compact order items list
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: order.menuItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = order.menuItems[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Quantity
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppPallete.primaryColor.withOpacitySafe(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        item.quantity.toString(),
                        style: TextStyle(
                          color: AppPallete.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Item name
                  Expanded(
                    child: Text(
                      item.menu.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Price
                  Text(
                    item.totalPrice.toIDRFormat(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: DottedDivider(color: AppPallete.neutralColor),
          ),

          // Payment Details with improved styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                order.grossAmount.toIDRFormat(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Fee',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                order.serviceFee.toIDRFormat(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Container(
              height: 1,
              color: AppPallete.neutralColor.shade300,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payment',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                (order.grossAmount + order.serviceFee).toIDRFormat(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppPallete.primaryColor,
                    ),
              ),
            ],
          ),

          // Additional Notes (if any)
          if (order.note.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Additional Notes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPallete.neutralColor.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppPallete.neutralColor.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    color: AppPallete.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.note,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.rejected:
        return Colors.red;
      case TransactionStatus.preparing:
        return Colors.blue;
      case TransactionStatus.ready:
        return AppPallete.primaryColor;
      case TransactionStatus.completed:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.rejected:
        return Icons.cancel;
      case TransactionStatus.preparing:
        return Icons.restaurant;
      case TransactionStatus.ready:
        return Icons.delivery_dining;
      case TransactionStatus.completed:
        return Icons.check_circle;
    }
  }

  // Improved horizontal timeline design
  Widget _buildStatusTimeline(BuildContext context, TransactionStatus status) {
    final bool isPreparing = status == TransactionStatus.preparing;
    final bool isCompleted = status == TransactionStatus.completed;
    final bool isRejected = status == TransactionStatus.rejected;
    final bool isPending = status == TransactionStatus.pending;
    final bool isReady = status == TransactionStatus.ready;

    if (isRejected) {
      return _buildCancelledStatus();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimelineStep(
              title: 'Confirmed',
              isActive: isPending || isReady || isPreparing || isCompleted,
              isCompleted: isReady || isPreparing || isCompleted,
              icon: Icons.receipt_long,
            ),
            _buildTimelineLine(
              isActive: isReady || isPreparing || isCompleted,
            ),
            _buildTimelineStep(
              title: 'Preparing',
              isActive: isPreparing || isCompleted,
              isCompleted: isCompleted,
              icon: Icons.restaurant,
            ),
            _buildTimelineLine(
              isActive: isCompleted,
            ),
            _buildTimelineStep(
              title: 'Completed',
              isActive: isCompleted,
              isCompleted: isCompleted,
              icon: Icons.check_circle,
            ),
          ],
        ),
        // Current step description
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacitySafe(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                _getCurrentStepDescription(status),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCurrentStepDescription(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Restaurant is reviewing your order';
      case TransactionStatus.rejected:
        return 'This order has been rejected';
      case TransactionStatus.preparing:
        return 'Your food is being prepared by the chef';
      case TransactionStatus.ready:
        return 'Your order is ready for pickup/delivery';
      case TransactionStatus.completed:
        return 'Your order has been completed!';
    }
  }

  Widget _buildTimelineStep({
    required String title,
    required bool isActive,
    required bool isCompleted,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppPallete.primaryColor
                : isActive
                    ? AppPallete.primaryColor.withOpacitySafe(0.1)
                    : Colors.grey.shade200,
            border: Border.all(
              color: isActive ? AppPallete.primaryColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted
                ? Colors.white
                : isActive
                    ? AppPallete.primaryColor
                    : Colors.grey.shade400,
            size: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppPallete.primaryColor : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine({required bool isActive}) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppPallete.primaryColor : Colors.grey.shade300,
    );
  }

  Widget _buildCancelledStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  'Order Rejected',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This order has been rejected by the restaurant',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
