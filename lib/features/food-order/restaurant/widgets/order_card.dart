import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/restaurant/widgets/order_details_sheet.dart';
import 'package:socieaty/features/food-order/restaurant/viewmodel/update_food_order_status_view_model.dart';
import 'package:socieaty/features/food-order/restaurant/provider/get_restaurant_food_order_provider.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class OrderCard extends ConsumerWidget {
  final FoodOrderTransaction order;
  final List<FoodOrderStatus> statusFilter;
  final Function(FoodOrderTransaction)? onViewDetails;

  const OrderCard({
    super.key,
    required this.order,
    required this.statusFilter,
    this.onViewDetails,
  });

  void _showOrderDetails(BuildContext context, FoodOrderTransaction order) {
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
          scrollController: scrollController,
          statusFilter: statusFilter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColors = {
      FoodOrderStatus.pending: Colors.orange,
      FoodOrderStatus.rejected: Colors.red,
      FoodOrderStatus.preparing: Colors.blue,
      FoodOrderStatus.ready: Colors.amber,
      FoodOrderStatus.completed: Colors.green,
    };

    final statusNames = {
      FoodOrderStatus.pending: 'MENUNGGU',
      FoodOrderStatus.rejected: 'DITOLAK',
      FoodOrderStatus.preparing: 'MENYIAPKAN',
      FoodOrderStatus.ready: 'SIAP',
      FoodOrderStatus.completed: 'SELESAI',
    };

    ref.listen(updateFoodOrderStatusViewModelProvider(order.orderId), (previous, next) {
      switch (next.updatedOrder) {
        case SuccessState<FoodOrderTransaction>():
          if (next.updatedOrder is SuccessState<FoodOrderTransaction>) {
            ref.invalidate(getRestaurantFoodOrderProvider(statusFilter));
          }
        case ErrorState(message: var message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState<FoodOrderTransaction>():
        case IdleState():
      }
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () =>
            onViewDetails != null ? onViewDetails!(order) : _showOrderDetails(context, order),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColors[order.foodOrderStatus]!.withAlpha(25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pesanan #${order.orderId.substring(order.orderId.length - 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColors[order.foodOrderStatus],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusNames[order.foodOrderStatus] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProfilePictureWidget(
                        user: UserConverter.customerToUser(order.customer),
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          order.customer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (order.menuItems.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            order.menuItems.first.menu.pictureUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.menuItems.first.quantity}× ${order.menuItems.first.menu.name}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              if (order.menuItems.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '+ ${order.menuItems.length - 1} ${order.menuItems.length > 2 ? "item lainnya" : "item lainnya"}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${order.menuItems.length} item total',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                  Text(
                                    'Rp ${(order.grossAmount + order.serviceFee).toIDRFormat()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (order.foodOrderStatus == FoodOrderStatus.pending)
                    PendingOrderCardActions(
                      order: order,
                      onViewDetails: onViewDetails != null
                          ? onViewDetails!
                          : (order) => _showOrderDetails(context, order),
                    ),
                  if (order.foodOrderStatus == FoodOrderStatus.preparing)
                    PreparingOrderCardActions(
                      order: order,
                      onViewDetails: onViewDetails != null
                          ? onViewDetails!
                          : (order) => _showOrderDetails(context, order),
                    ),
                  if (order.foodOrderStatus == FoodOrderStatus.ready)
                    ReadyOrderCardActions(
                      order: order,
                      onViewDetails: onViewDetails != null
                          ? onViewDetails!
                          : (order) => _showOrderDetails(context, order),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingOrderCardActions extends ConsumerWidget {
  final FoodOrderTransaction order;
  final Function(FoodOrderTransaction) onViewDetails;

  const PendingOrderCardActions({
    super.key,
    required this.order,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onViewDetails(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Lihat Detail'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () {
                ref
                    .read(updateFoodOrderStatusViewModelProvider(order.orderId).notifier)
                    .updateTransactionStatus(FoodOrderStatus.preparing);
              },
              child: const Text('Terima'),
            ),
          ),
        ],
      ),
    );
  }
}

class PreparingOrderCardActions extends ConsumerWidget {
  final FoodOrderTransaction order;
  final Function(FoodOrderTransaction) onViewDetails;

  const PreparingOrderCardActions({
    super.key,
    required this.order,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onViewDetails(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Lihat Detail'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () {
                ref
                    .read(updateFoodOrderStatusViewModelProvider(order.orderId).notifier)
                    .updateTransactionStatus(FoodOrderStatus.ready);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Siap Diambil'),
            ),
          ),
        ],
      ),
    );
  }
}

class ReadyOrderCardActions extends ConsumerWidget {
  final FoodOrderTransaction order;
  final Function(FoodOrderTransaction) onViewDetails;

  const ReadyOrderCardActions({
    super.key,
    required this.order,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onViewDetails(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Lihat Detail'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () {
                ref
                    .read(updateFoodOrderStatusViewModelProvider(order.orderId).notifier)
                    .updateTransactionStatus(FoodOrderStatus.completed);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Selesai'),
            ),
          ),
        ],
      ),
    );
  }
}
