import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socieaty/core/notifications/local_notification_service.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/home/restaurant/view/grid_menu_button_widget.dart';
import 'package:socieaty/features/home/restaurant/view/recent_reservation_widget.dart';
import 'package:socieaty/features/home/restaurant/view/statistic_summary_widget.dart';
import 'package:socieaty/features/restaurant/socket/restaurant_socket_service.dart';
import 'package:socieaty/features/restaurant/view/restaurant_scaffold_with_navbar.dart';
import 'package:socieaty/features/transaction/restaurant/view/transaction_item_summary_widget.dart';

class RestaurantDashboardScreen extends ConsumerStatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  ConsumerState<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends ConsumerState<RestaurantDashboardScreen> {
  @override
  void initState() {
    super.initState();

    debugPrint("Initializing socket connection");
    initializeSocketConnection();

    setupNotificationTapHandling();

    requestNotificationPermissions();
  }

  void initializeSocketConnection() {
    ref.read(restaurantSocketServiceProvider).initConnection();

    ref.read(restaurantSocketServiceProvider).listenNewOrder((orderData) {
      debugPrint('Order received in dashboard: $orderData');
    });
  }

  void navigateToOrderDetails(String orderId) {
    ref.read(restaurantScaffoldPageControllerProvider).pushNewBranch(1);
  }

  void setupNotificationTapHandling() {
    // Set up notification tap handler
    ref.read(localNotificationServiceProvider).setOnNotificationTap((String? orderId) {
      if (orderId != null) {
        debugPrint('Navigating to order details for order: $orderId');
        navigateToOrderDetails(orderId);
      }
    });
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
    debugPrint('Opening app settings to enable notifications');
  }

  Future<void> requestNotificationPermissions() async {
    final notificationService = ref.read(localNotificationServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));

      final status = await Permission.notification.status;
      if (status.isGranted) {
        debugPrint('Notification permission already granted');
        return;
      }

      final bool granted = await notificationService.requestPermissions();

      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification permissions are required to receive order alerts.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authLocalRepositoryProvider).getUserData();

    return Scaffold(
      backgroundColor: AppPallete.primaryColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppPallete.neutralColor.shade50,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: const AssetImage('assets/images/person_dummy.jpg'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user!.name,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.white70, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Jakarta, Indonesia',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white70,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.5',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        ' (2.3k reviews)',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white70,
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
                    ),
                  ),
                ),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.space_dashboard,
                            size: 24,
                            color: AppPallete.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Menu',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(25),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                          children: [
                            GridMenuButtonWidget(
                              icon: Icons.store,
                              label: 'Outlet',
                              color: Colors.blue,
                              onTap: () {
                                context.push('/restaurant/dashboard/outlet');
                              },
                            ),
                            GridMenuButtonWidget(
                              icon: Icons.point_of_sale,
                              label: 'Penjualan',
                              color: Colors.green,
                              onTap: () {},
                            ),
                            GridMenuButtonWidget(
                              icon: Icons.calendar_today,
                              label: 'Reservasi',
                              color: Colors.orange,
                              onTap: () {},
                            ),
                            GridMenuButtonWidget(
                              icon: Icons.live_tv,
                              label: 'Konten',
                              color: Colors.red,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Recent Transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transaksi Terakhir',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View All',
                              style: TextStyle(color: AppPallete.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TransactionItemSummaryWidget(
                        customerName: 'John Doe',
                        time: '2 hours ago',
                        amount: 'Rp 150.000',
                        status: 'Completed',
                      ),

                      const SizedBox(height: 16),

                      // Recent Reservations
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reservasi Mendatang',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View All',
                              style: TextStyle(color: AppPallete.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RecentReservationWidget(),

                      const SizedBox(height: 24),

                      // Statistics Cards
                      Text(
                        'Statistik Hari Ini',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatisticSummaryWidget(
                              title: 'Revenue',
                              value: 'Rp 2.5M',
                              increase: '+15%',
                              icon: Icons.trending_up,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatisticSummaryWidget(
                              title: 'Orders',
                              value: '45',
                              increase: '+8%',
                              icon: Icons.receipt_long,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Engagement Section
                      Text(
                        'Social Engagement',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(25),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildEngagementMetric(
                                  context,
                                  icon: Icons.remove_red_eye,
                                  value: '10.5K',
                                  label: 'Views',
                                  color: Colors.purple,
                                ),
                                _buildEngagementMetric(
                                  context,
                                  icon: Icons.favorite,
                                  value: '2.3K',
                                  label: 'Likes',
                                  color: Colors.red,
                                ),
                                _buildEngagementMetric(
                                  context,
                                  icon: Icons.comment,
                                  value: '1.2K',
                                  label: 'Comments',
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEngagementMetric(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
