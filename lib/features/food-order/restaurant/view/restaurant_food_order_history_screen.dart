import 'package:flutter/material.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/features/food-order/restaurant/widgets/order_list.dart';

class RestaurantFoodOrderHistoryScreen extends StatefulWidget {
  const RestaurantFoodOrderHistoryScreen({super.key});

  @override
  State<RestaurantFoodOrderHistoryScreen> createState() => _RestaurantFoodOrderHistoryScreenState();
}

class _RestaurantFoodOrderHistoryScreenState extends State<RestaurantFoodOrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(178), // 70% of 255
          tabs: const [
            Tab(text: 'Selesai'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrderList(
            statusFilter: [FoodOrderStatus.completed],
          ),
          OrderList(
            statusFilter: [FoodOrderStatus.rejected],
          ),
        ],
      ),
    );
  }
}
