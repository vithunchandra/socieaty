import 'package:flutter/material.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/features/transaction/restaurant/widgets/order_list.dart';

class RestaurantTransactionHistoryScreen extends StatefulWidget {
  const RestaurantTransactionHistoryScreen({super.key});

  @override
  State<RestaurantTransactionHistoryScreen> createState() =>
      _RestaurantTransactionHistoryScreenState();
}

class _RestaurantTransactionHistoryScreenState extends State<RestaurantTransactionHistoryScreen>
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
            statusFilter: [TransactionStatus.completed],
          ),
          OrderList(
            statusFilter: [TransactionStatus.rejected],
          ),
        ],
      ),
    );
  }
}
