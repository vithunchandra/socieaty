import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food-order/customer/widgets/qr_code_dialog.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class ActiveOrderView extends ConsumerStatefulWidget {
  final FoodOrderTransaction order;
  final ScrollController scrollController;
  final Function() navigateToMapScreen;
  final bool isLoadingLocation;

  const ActiveOrderView({
    super.key,
    required this.order,
    required this.scrollController,
    required this.navigateToMapScreen,
    this.isLoadingLocation = false,
  });

  @override
  ConsumerState<ActiveOrderView> createState() => _ActiveOrderViewState();
}

class _ActiveOrderViewState extends ConsumerState<ActiveOrderView> {
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

  void _showQRCodeDialog() {
    final token = ref.read(authLocalRepositoryProvider).getToken();
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(order: widget.order, token: token!),
    );
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
                        'Estimasi Pengantaran',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        '15-20 menit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.isLoadingLocation ? null : widget.navigateToMapScreen,
                  icon: widget.isLoadingLocation
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: LoadingIndicatorWidget(
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.map, size: 16, color: Colors.white),
                  label: Text(widget.isLoadingLocation ? 'Memuat...' : 'Lihat Peta'),
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
            child: _buildStatusTimeline(context, order.foodOrderStatus),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: _buildStatusMessage(order),
          ),
          if (order.foodOrderStatus == FoodOrderStatus.ready)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: _buildQrCodeButton(),
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

  Widget _buildQrCodeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showQRCodeDialog,
        icon: const Icon(Icons.qr_code, size: 18),
        label: const Text('Tunjukkan QR Code'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(FoodOrderTransaction order) {
    final Color statusColor = _getStatusColor(order.foodOrderStatus);

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
            _getStatusIcon(order.foodOrderStatus),
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusMessage(order.foodOrderStatus),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    order.foodOrderStatus == FoodOrderStatus.ready
                        ? 'Silakan ambil pesanan Anda'
                        : 'Pesanan sedang diproses',
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
                        "Lokasi Restoran",
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
              context.push('/transaction/message',
                  extra: TransactionConverter.foodOrderToTransaction(order));
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
                'Ringkasan Pesanan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${order.menuItems.length} item',
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
                'Biaya Layanan',
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
                'Total Pembayaran',
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
              'Catatan Tambahan',
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

  Widget _buildStatusTimeline(BuildContext context, FoodOrderStatus status) {
    final bool isPending = status == FoodOrderStatus.pending;
    final bool isPreparing = status == FoodOrderStatus.preparing;
    final bool isReady = status == FoodOrderStatus.ready;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimelineStep(
              title: 'Dikonfirmasi',
              isActive: true,
              isCompleted: isPreparing || isReady,
              icon: Icons.receipt_long,
            ),
            _buildTimelineLine(
              isActive: isPreparing || isReady,
            ),
            _buildTimelineStep(
              title: 'Diproses',
              isActive: isPreparing || isReady,
              isCompleted: isReady,
              icon: Icons.restaurant,
            ),
            _buildTimelineLine(
              isActive: isReady,
            ),
            _buildTimelineStep(
              title: 'Siap',
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

  Color _getStatusColor(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.pending:
        return Colors.orange;
      case FoodOrderStatus.preparing:
        return Colors.blue;
      case FoodOrderStatus.ready:
        return AppPallete.primaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.pending:
        return Icons.schedule;
      case FoodOrderStatus.preparing:
        return Icons.restaurant;
      case FoodOrderStatus.ready:
        return Icons.delivery_dining;
      default:
        return Icons.info;
    }
  }

  String _getStatusMessage(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.pending:
        return 'Menunggu konfirmasi restoran';
      case FoodOrderStatus.preparing:
        return 'Makanan sedang disiapkan';
      case FoodOrderStatus.ready:
        return 'Pesanan siap diambil';
      default:
        return '';
    }
  }

  String _getCurrentStepDescription(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.pending:
        return 'Restoran sedang meninjau pesanan Anda';
      case FoodOrderStatus.preparing:
        return 'Makanan Anda sedang dipersiapkan oleh koki';
      case FoodOrderStatus.ready:
        return 'Makanan siap! Silakan ambil pesanan Anda.';
      default:
        return '';
    }
  }
}
