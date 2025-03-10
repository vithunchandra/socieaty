import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/core/utils/custom_extension.dart';

class ActiveOrderView extends StatefulWidget {
  final FoodOrderTransaction order;
  final ScrollController scrollController;
  final Function() navigateToMapScreen;

  const ActiveOrderView({
    super.key,
    required this.order,
    required this.scrollController,
    required this.navigateToMapScreen,
  });

  @override
  State<ActiveOrderView> createState() => _ActiveOrderViewState();
}

class _ActiveOrderViewState extends State<ActiveOrderView> {
  bool _isHeaderCollapsed = false;

  void handleScroll() {
    if (!widget.scrollController.hasClients) return;

    final double offset = widget.scrollController.offset;
    final threshold = 100.0;
    final isCollapsed = offset > threshold;

    if (isCollapsed != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(handleScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          handleScroll();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          children: [
            _buildFixedHeader(widget.order),
            _buildContent(widget.order),
            const SizedBox(height: 28),
          ],
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
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
                  onPressed: widget.navigateToMapScreen,
                  icon: const Icon(Icons.map, size: 16, color: Colors.white),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: _buildStatusTimeline(context, order.status),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: _buildStatusMessage(order),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: _buildRestaurantSection(order),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
            child: _buildOrderSummary(order),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(FoodOrderTransaction order) {
    final Color statusColor = _getStatusColor(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withAlpha(75)),
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
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    order.status == TransactionStatus.ready
                        ? 'Please proceed to the restaurant to pick up your order'
                        : 'Please wait while we process your order',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
            color: Colors.grey.withAlpha(25),
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
          InkWell(
            onTap: () {
              context.push('/track-order/message', extra: order);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppPallete.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat, size: 16, color: AppPallete.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Chat',
                    style: TextStyle(
                      color: AppPallete.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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
            color: Colors.grey.withAlpha(25),
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
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppPallete.primaryColor.withAlpha(25),
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

  Widget _buildStatusTimeline(BuildContext context, TransactionStatus status) {
    final bool isPending = status == TransactionStatus.pending;
    final bool isPreparing = status == TransactionStatus.preparing;
    final bool isReady = status == TransactionStatus.ready;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimelineStep(
              title: 'Confirmed',
              isActive: true,
              isCompleted: isPreparing || isReady,
              icon: Icons.receipt_long,
            ),
            _buildTimelineLine(
              isActive: isPreparing || isReady,
            ),
            _buildTimelineStep(
              title: 'Preparing',
              isActive: isPreparing || isReady,
              isCompleted: isReady,
              icon: Icons.restaurant,
            ),
            _buildTimelineLine(
              isActive: isReady,
            ),
            _buildTimelineStep(
              title: 'Ready',
              isActive: isReady,
              isCompleted: false,
              icon: Icons.delivery_dining,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(25),
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
                    ? AppPallete.primaryColor.withAlpha(25)
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

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.preparing:
        return Colors.blue;
      case TransactionStatus.ready:
        return AppPallete.primaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.preparing:
        return Icons.restaurant;
      case TransactionStatus.ready:
        return Icons.delivery_dining;
      default:
        return Icons.info;
    }
  }

  String _getStatusMessage(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Restaurant is reviewing your order';
      case TransactionStatus.preparing:
        return 'Your food is being prepared';
      case TransactionStatus.ready:
        return 'Your order is ready for pickup';
      default:
        return '';
    }
  }

  String _getCurrentStepDescription(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Restaurant is reviewing your order';
      case TransactionStatus.preparing:
        return 'Your food is being prepared by the chef';
      case TransactionStatus.ready:
        return 'Your food is ready! Please pick up your order.';
      default:
        return '';
    }
  }
}
