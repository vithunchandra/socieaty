import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

class OrderCard extends StatelessWidget {
  final FoodOrderTransaction order;
  final bool isActive;

  const OrderCard({
    super.key,
    required this.order,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.foodOrderStatus);

    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: AppPallete.neutralColor.withAlpha(128),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/track-order', extra: order.orderId);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isActive) _buildActiveBadge(context),
            _buildRestaurantInfo(context, statusColor),
            if (isActive) _buildProgressBar(context),
            _buildOrderItems(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBadge(BuildContext context) {
    String statusText;
    Color bgColor;

    switch (order.foodOrderStatus) {
      case FoodOrderStatus.pending:
        statusText = 'Order Placed';
        bgColor = Colors.blue.shade700;
      case FoodOrderStatus.preparing:
        statusText = 'Preparing';
        bgColor = Colors.orange.shade700;
      case FoodOrderStatus.ready:
        statusText = 'Ready for Pickup';
        bgColor = Colors.green.shade700;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          statusText,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo(BuildContext context, Color statusColor) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              order.restaurant.restaurantData.restaurantBannerUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: AppPallete.neutralColor.shade200,
                child: Icon(Icons.restaurant, color: AppPallete.neutralColor.shade50),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurant.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: isActive ? 17 : 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (!isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(order.foodOrderStatus),
                          style: textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (!isActive) const SizedBox(width: 6),
                    Text(
                      isActive
                          ? 'Order #${_getOrderIdSubstring()}'
                          : '• Order #${_getOrderIdSubstring()}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPallete.neutralColor.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getOrderIdSubstring() {
    if (order.orderId.isEmpty) {
      return '';
    }
    return order.orderId.length >= 4 ? order.orderId.substring(0, 4) : order.orderId;
  }

  Widget _buildProgressBar(BuildContext context) {
    int currentStep;
    switch (order.foodOrderStatus) {
      case FoodOrderStatus.pending:
        currentStep = 0;
      case FoodOrderStatus.preparing:
        currentStep = 1;
      case FoodOrderStatus.ready:
        currentStep = 2;
      default:
        return const SizedBox.shrink();
    }

    final labels = ['Order Placed', 'Preparing', 'Ready'];
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index <= currentStep
                                  ? AppPallete.primaryColor
                                  : AppPallete.neutralColor.shade200,
                            ),
                          ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? AppPallete.primaryColor : Colors.white,
                            border: Border.all(
                              color: isActive
                                  ? AppPallete.primaryColor
                                  : AppPallete.neutralColor.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: isActive
                              ? const Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        if (index < 2)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index < currentStep
                                  ? AppPallete.primaryColor
                                  : AppPallete.neutralColor.shade200,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive
                            ? AppPallete.neutralColor.shade800
                            : AppPallete.neutralColor.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    final menuItems = order.menuItems;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
              height: 1,
              color: isActive
                  ? AppPallete.primaryColor.withOpacity(0.2)
                  : AppPallete.neutralColor.shade200),
          const SizedBox(height: 12),
          ...menuItems.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppPallete.primaryColor.withOpacity(0.1)
                            : AppPallete.neutralColor.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.quantity}×',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              isActive ? AppPallete.primaryColor : AppPallete.neutralColor.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.menu.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      'Rp ${(item.menu.price * item.quantity).toIDRFormat()}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
          if (menuItems.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 10),
              child: Text(
                "+ ${menuItems.length - 2} more items",
                style: textTheme.bodySmall?.copyWith(
                  color: AppPallete.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Divider(
              height: 1,
              color: isActive
                  ? AppPallete.primaryColor.withOpacity(0.2)
                  : AppPallete.neutralColor.shade200),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: AppPallete.neutralColor.shade800,
                  ),
                ),
                Text(
                  'Rp ${order.grossAmount.toIDRFormat()}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: isActive ? 17 : 16,
                    color: isActive ? AppPallete.primaryColor : AppPallete.neutralColor.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (isActive) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton(
          onPressed: () {
            context.push('/track-order', extra: order.orderId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Track Order',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      final isCompleted = order.foodOrderStatus == FoodOrderStatus.completed;
      final statusColor = isCompleted ? Colors.green.shade600 : Colors.red.shade600;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 18,
              color: statusColor,
            ),
            const SizedBox(width: 8),
            Text(
              isCompleted ? 'Order was completed' : 'Order was cancelled',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.push('/track-order', extra: order.orderId);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('Details'),
            ),
          ],
        ),
      );
    }
  }

  Color _getStatusColor(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.pending:
        return Colors.blue.shade600;
      case FoodOrderStatus.preparing:
        return Colors.orange.shade600;
      case FoodOrderStatus.ready:
        return Colors.green.shade600;
      case FoodOrderStatus.completed:
        return Colors.green.shade600;
      case FoodOrderStatus.rejected:
        return Colors.red.shade600;
    }
  }

  String _getStatusText(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.pending:
        return 'Order Placed';
      case FoodOrderStatus.preparing:
        return 'Preparing';
      case FoodOrderStatus.ready:
        return 'Ready';
      case FoodOrderStatus.completed:
        return 'Completed';
      case FoodOrderStatus.rejected:
        return 'Cancelled';
    }
  }
}
