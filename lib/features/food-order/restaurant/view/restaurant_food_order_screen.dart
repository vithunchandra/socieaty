import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/customer/provider/get_food_order_provider.dart';
import 'package:socieaty/features/food-order/restaurant/widgets/order_details_sheet.dart';
import 'package:socieaty/features/food-order/restaurant/widgets/order_list.dart';
import 'package:socieaty/features/qr_code_scanner/view/qr_code_scanner_screen.dart';

class RestaurantFoodOrderScreen extends ConsumerStatefulWidget {
  final FoodOrderTransaction? order;

  const RestaurantFoodOrderScreen({super.key, this.order});

  @override
  ConsumerState<RestaurantFoodOrderScreen> createState() => _RestaurantFoodOrderScreenState();
}

class _RestaurantFoodOrderScreenState extends ConsumerState<RestaurantFoodOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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

  void _showHighlightedOrder(FoodOrderTransaction order) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
            statusFilter: [FoodOrderStatus.pending],
            scrollController: scrollController,
          ),
        ),
      );
    });
  }

  Future<void> _handleOrderScan(BuildContext context) async {
    final result = await context.push(
      '/qr-code-scanner',
      extra: const QrCodeScannerArgs(
        title: 'Scan Order QR',
        helperMessage: 'Scan customer order QR code to verify',
      ),
    );

    if (result == null) {
      if (context.mounted) {
        showSnackbar(context, 'QR code scan gagal', state: SnackbarState.error);
      }
      return;
    }

    if (result is! String) {
      if (context.mounted) {
        showSnackbar(context, 'QR code tidak valid', state: SnackbarState.error);
      }
      return;
    }

    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    final orderId = result.toString();

    try {
      final order = await ref.read(getFoodOrderProvider(orderId).future);

      if (context.mounted) {
        _showHighlightedOrder(order);
      }
    } catch (err) {
      if (context.mounted) {
        showSnackbar(context, 'Pesanan tidak ditemukan', state: SnackbarState.error);
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              context.push('/restaurant/dashboard/food-order/history');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(178),
          tabs: const [
            Tab(text: 'Baru'),
            Tab(text: 'Berlangsung'),
            Tab(text: 'Siap'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrderList(
            statusFilter: [FoodOrderStatus.pending],
            onViewOrderDetails: _showHighlightedOrder,
          ),
          OrderList(
            statusFilter: [FoodOrderStatus.preparing],
            onViewOrderDetails: _showHighlightedOrder,
          ),
          OrderList(
            statusFilter: [FoodOrderStatus.ready],
            onViewOrderDetails: _showHighlightedOrder,
          ),
        ],
      ),
      floatingActionButton: StatefulBuilder(builder: (context, setState) {
        _tabController.addListener(() {
          setState(() {});
        });
        return _tabController.index == 2
            ? FloatingActionButton(
                onPressed: () => _handleOrderScan(context),
                backgroundColor: AppPallete.primaryColor,
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
              )
            : const SizedBox.shrink();
      }),
    );
  }
}
