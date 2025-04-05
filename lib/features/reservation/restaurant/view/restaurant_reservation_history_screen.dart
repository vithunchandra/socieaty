import 'package:flutter/material.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/restaurant_paginated_reservation_list.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_list.dart';

class RestaurantReservationHistoryScreen extends StatefulWidget {
  const RestaurantReservationHistoryScreen({super.key});

  @override
  State<RestaurantReservationHistoryScreen> createState() =>
      _RestaurantReservationHistoryScreenState();
}

class _RestaurantReservationHistoryScreenState extends State<RestaurantReservationHistoryScreen>
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
          'Riwayat Reservasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(178),
          tabs: const [
            Tab(text: 'Selesai'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RestaurantPaginatedReservationList(
            status: [ReservationStatus.completed],
          ),
          RestaurantPaginatedReservationList(
            status: [ReservationStatus.rejected],
          ),
        ],
      ),
    );
  }
}
