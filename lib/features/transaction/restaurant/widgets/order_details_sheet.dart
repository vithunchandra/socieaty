import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/restaurant/provider/get_restaurant_food_transaction_provider.dart';
import 'package:socieaty/features/transaction/restaurant/viewmodel/update_transaction_status_view_model.dart';
import 'package:socieaty/shared/view_state.dart';

class OrderDetailsSheet extends ConsumerStatefulWidget {
  final FoodOrderTransaction order;
  final ScrollController scrollController;
  final List<TransactionStatus> statusFilter;

  const OrderDetailsSheet(
      {super.key, required this.order, required this.scrollController, required this.statusFilter});

  @override
  ConsumerState<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends ConsumerState<OrderDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    final statusColors = {
      TransactionStatus.pending: Colors.orange,
      TransactionStatus.rejected: Colors.red,
      TransactionStatus.preparing: Colors.blue,
      TransactionStatus.ready: Colors.amber,
      TransactionStatus.completed: Colors.green,
    };

    final statusNames = {
      TransactionStatus.pending: 'MENUNGGU',
      TransactionStatus.rejected: 'DITOLAK',
      TransactionStatus.preparing: 'MENYIAPKAN',
      TransactionStatus.ready: 'SIAP',
      TransactionStatus.completed: 'SELESAI',
    };

    ref.listen(updateTransactionStatusViewModelProvider(widget.order.id), (previous, next) {
      switch (next.updatedOrder) {
        case SuccessState<FoodOrderTransaction>():
          if (widget.order.status == TransactionStatus.pending) {
            ref.invalidate(getRestaurantFoodTransactionProvider(widget.statusFilter));
          }
          context.pop();

        case ErrorState(message: var message):
          showSnackbar(context, message, isError: true);
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
                      'Pesanan #${widget.order.id.substring(widget.order.id.length - 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColors[widget.order.status]?.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusNames[widget.order.status] ?? '',
                        style: TextStyle(
                          color: statusColors[widget.order.status],
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
                  leading: CircleAvatar(
                    backgroundImage: widget.order.customer.profilePictureUrl != null
                        ? NetworkImage(widget.order.customer.profilePictureUrl!)
                        : null,
                    radius: 20,
                    child: widget.order.customer.profilePictureUrl == null
                        ? Text(widget.order.customer.name[0])
                        : null,
                  ),
                  title: Text(
                    widget.order.customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
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
                    Text('Rp ${widget.order.grossAmount.toIDRFormat()}'),
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
          if (widget.order.status == TransactionStatus.pending)
            PendingOrderDetailsActions(order: widget.order),
          if (widget.order.status == TransactionStatus.preparing)
            PreparingOrderDetailsActions(order: widget.order),
          if (widget.order.status == TransactionStatus.ready)
            ReadyOrderDetailsActions(order: widget.order),
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ref
                    .read(updateTransactionStatusViewModelProvider(widget.order.id).notifier)
                    .updateTransactionStatus(TransactionStatus.rejected);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Tolak Pesanan'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: () {
                ref
                    .read(updateTransactionStatusViewModelProvider(widget.order.id).notifier)
                    .updateTransactionStatus(TransactionStatus.preparing);
              },
              child: const Text('Terima Pesanan'),
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () {
                ref
                    .read(updateTransactionStatusViewModelProvider(widget.order.id).notifier)
                    .updateTransactionStatus(TransactionStatus.ready);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Pesanan Siap Diambil'),
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () {
                ref
                    .read(updateTransactionStatusViewModelProvider(widget.order.id).notifier)
                    .updateTransactionStatus(TransactionStatus.completed);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Pesanan Selesai'),
            ),
          ),
        ],
      ),
    );
  }
}
