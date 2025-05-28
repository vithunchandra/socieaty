import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/restaurant/provider/get_restaurant_food_order_provider.dart';
import 'package:socieaty/features/food-order/restaurant/viewmodel/update_food_order_status_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class OrderDetailsSheet extends ConsumerStatefulWidget {
  final FoodOrderTransaction order;
  final ScrollController scrollController;
  final List<FoodOrderStatus> statusFilter;
  final bool isActionEnabled;

  const OrderDetailsSheet({
    super.key,
    required this.order,
    required this.scrollController,
    required this.statusFilter,
    this.isActionEnabled = true,
  });

  @override
  ConsumerState<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends ConsumerState<OrderDetailsSheet> {
  @override
  Widget build(BuildContext context) {
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

    ref.listen(updateFoodOrderStatusViewModelProvider(widget.order.orderId), (previous, next) {
      switch (next.updatedOrder) {
        case SuccessState<FoodOrderTransaction>():
          ref.invalidate(getRestaurantFoodOrderProvider(widget.statusFilter));
          context.pop();

        case ErrorState(message: var message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState<FoodOrderTransaction>():
        case IdleState():
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pesanan #${widget.order.orderId.substring(widget.order.orderId.length - 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColors[widget.order.foodOrderStatus]?.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusNames[widget.order.foodOrderStatus] ?? '',
                        style: TextStyle(
                          color: statusColors[widget.order.foodOrderStatus],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Informasi Pelanggan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ProfilePictureWidget(
                    radius: 20,
                    user: UserConverter.customerToUser(widget.order.customer),
                  ),
                  title: Text(
                    widget.order.customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      context.push('/transaction/message',
                          extra: TransactionConverter.foodOrderToTransaction(widget.order));
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
                ),
                const Divider(height: 32),
                if (widget.order.note.isNotEmpty) ...[
                  const Text(
                    'Catatan Tambahan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_alt, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.order.note,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                ],
                const Text(
                  'Item Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.order.menuItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.menu.pictureUrl,
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
                                  item.menu.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${item.price.toIDRFormat()} x ${item.quantity}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${item.totalPrice.toIDRFormat()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 32),
                const Text(
                  'Detail Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('Rp ${widget.order.netAmount.toIDRFormat()}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Biaya Layanan'),
                    Text('Rp ${widget.order.serviceFee.toIDRFormat()}'),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${widget.order.grossAmount.toIDRFormat()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (widget.isActionEnabled) ...[
            if (widget.order.foodOrderStatus == FoodOrderStatus.pending)
              PendingOrderDetailsActions(order: widget.order),
            if (widget.order.foodOrderStatus == FoodOrderStatus.preparing)
              PreparingOrderDetailsActions(order: widget.order),
            if (widget.order.foodOrderStatus == FoodOrderStatus.ready)
              ReadyOrderDetailsActions(order: widget.order),
          ],
        ],
      ),
    );
  }
}

class PendingOrderDetailsActions extends ConsumerStatefulWidget {
  final FoodOrderTransaction order;
  const PendingOrderDetailsActions({super.key, required this.order});

  @override
  ConsumerState<PendingOrderDetailsActions> createState() => _PendingOrderDetailsActionsState();
}

class _PendingOrderDetailsActionsState extends ConsumerState<PendingOrderDetailsActions> {
  FoodOrderStatus? _lastUpdatedStatus;

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref
        .watch(updateFoodOrderStatusViewModelProvider(widget.order.orderId))
        .updatedOrder is LoadingState;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _lastUpdatedStatus = FoodOrderStatus.rejected;
                      });
                      ref
                          .read(
                              updateFoodOrderStatusViewModelProvider(widget.order.orderId).notifier)
                          .updateTransactionStatus(FoodOrderStatus.rejected);
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading && _lastUpdatedStatus == FoodOrderStatus.rejected
                  ? const LoadingIndicatorWidget(
                      size: 16,
                    )
                  : const Text('Tolak Pesanan'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _lastUpdatedStatus = FoodOrderStatus.preparing;
                      });
                      ref
                          .read(
                              updateFoodOrderStatusViewModelProvider(widget.order.orderId).notifier)
                          .updateTransactionStatus(FoodOrderStatus.preparing);
                    },
              child: isLoading && _lastUpdatedStatus == FoodOrderStatus.preparing
                  ? const LoadingIndicatorWidget(size: 16, color: Colors.white)
                  : const Text('Terima Pesanan'),
            ),
          ),
        ],
      ),
    );
  }
}

class PreparingOrderDetailsActions extends ConsumerStatefulWidget {
  final FoodOrderTransaction order;
  const PreparingOrderDetailsActions({super.key, required this.order});

  @override
  ConsumerState<PreparingOrderDetailsActions> createState() => _PreparingOrderDetailsActionsState();
}

class _PreparingOrderDetailsActionsState extends ConsumerState<PreparingOrderDetailsActions> {
  FoodOrderStatus? _lastUpdatedStatus;

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref
        .watch(updateFoodOrderStatusViewModelProvider(widget.order.orderId))
        .updatedOrder is LoadingState;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _lastUpdatedStatus = FoodOrderStatus.ready;
                      });
                      ref
                          .read(
                              updateFoodOrderStatusViewModelProvider(widget.order.orderId).notifier)
                          .updateTransactionStatus(FoodOrderStatus.ready);
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading && _lastUpdatedStatus == FoodOrderStatus.ready
                  ? const LoadingIndicatorWidget(size: 16, color: Colors.white)
                  : const Text('Pesanan Siap Diambil'),
            ),
          ),
        ],
      ),
    );
  }
}

class ReadyOrderDetailsActions extends ConsumerStatefulWidget {
  final FoodOrderTransaction order;
  const ReadyOrderDetailsActions({super.key, required this.order});

  @override
  ConsumerState<ReadyOrderDetailsActions> createState() => _ReadyOrderDetailsActionsState();
}

class _ReadyOrderDetailsActionsState extends ConsumerState<ReadyOrderDetailsActions> {
  FoodOrderStatus? _lastUpdatedStatus;

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref
        .watch(updateFoodOrderStatusViewModelProvider(widget.order.orderId))
        .updatedOrder is LoadingState;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _lastUpdatedStatus = FoodOrderStatus.completed;
                      });
                      ref
                          .read(
                              updateFoodOrderStatusViewModelProvider(widget.order.orderId).notifier)
                          .updateTransactionStatus(FoodOrderStatus.completed);
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.successColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading && _lastUpdatedStatus == FoodOrderStatus.completed
                  ? const LoadingIndicatorWidget(size: 16, color: Colors.white)
                  : const Text('Pesanan Selesai'),
            ),
          ),
        ],
      ),
    );
  }
}
