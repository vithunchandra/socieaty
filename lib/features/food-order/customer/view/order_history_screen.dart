import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/food-order/customer/provider/get_all_food_order_transactions_provider.dart';
import 'package:socieaty/features/food-order/customer/widgets/order_list.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<FoodOrderStatus> _activeStatuses = [
    FoodOrderStatus.pending,
    FoodOrderStatus.preparing,
    FoodOrderStatus.ready
  ];

  final List<FoodOrderStatus> _pastStatuses = [FoodOrderStatus.completed, FoodOrderStatus.rejected];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppPallete.neutralColor.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Orderan Saya',
          style: textTheme.titleLarge?.copyWith(
            color: AppPallete.neutralColor.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8, bottom: 0),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              labelColor: AppPallete.primaryColor,
              unselectedLabelColor: AppPallete.neutralColor.shade600,
              indicatorColor: AppPallete.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppPallete.primaryColor,
                    width: 3,
                  ),
                ),
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return states.contains(WidgetState.focused) ? null : Colors.transparent;
                },
              ),
              labelStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: const [
                Tab(
                  text: 'Pesanan Aktif',
                ),
                Tab(
                  text: 'Riwayat Pesanan',
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppPallete.neutralColor.shade200,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OrderList(
                  statuses: _activeStatuses,
                  isActiveTab: true,
                  onRefresh: () =>
                      ref.invalidate(getAllFoodOrderTransactionsProvider(_activeStatuses)),
                ),
                OrderList(
                  statuses: _pastStatuses,
                  isActiveTab: false,
                  onRefresh: () =>
                      ref.invalidate(getAllFoodOrderTransactionsProvider(_pastStatuses)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
