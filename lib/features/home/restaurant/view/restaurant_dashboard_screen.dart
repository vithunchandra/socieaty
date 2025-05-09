import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/notifications/local_notification_service.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food-order/restaurant/provider/order_changes_notification_provider.dart';
import 'package:socieaty/features/home/restaurant/view/grid_menu_button_widget.dart';
import 'package:socieaty/features/home/restaurant/view/recent_reservation_widget.dart';
import 'package:socieaty/features/home/restaurant/view/statistic_summary_widget.dart';
import 'package:socieaty/features/food-order/restaurant/socket/restaurant_socket_service.dart';
import 'package:socieaty/features/reservation/restaurant/provider/new_reservation_notification_provider.dart';
import 'package:socieaty/features/reservation/restaurant/provider/reservation_changes_notification_provider.dart';
import 'package:socieaty/features/reservation/restaurant/socket/restaurant_reservation_socket_service.dart';
import 'package:socieaty/features/restaurant/view/restaurant_scaffold_with_navbar.dart';
import 'package:socieaty/features/food-order/restaurant/view/food_order_item_summary_widget.dart';
import 'package:socieaty/features/food-order/restaurant/provider/new_order_notification_provider.dart';
import 'package:socieaty/shared/widgets/create_screen.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:toastification/toastification.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:socieaty/features/account/customer/viewmodel/account_view_model.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class RestaurantDashboardScreen extends ConsumerStatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  ConsumerState<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends ConsumerState<RestaurantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    initializeSocketConnection();
    requestNotificationPermissions();
  }

  void initializeSocketConnection() {
    final orderSocketService = ref.read(restaurantSocketServiceProvider);
    orderSocketService.initConnection(
      onNewOrderCallback: (order) {
        ref.read(newOrderNotificationProvider.notifier).setNewOrder(order);
      },
      onNewOrderNotificationTap: (orderId) {
        context.push('/restaurant/dashboard/food-order', extra: orderId);
      },
      onOrderChangesCallback: (order) {
        ref.read(orderChangesNotificationProvider.notifier).setOrder(order);
      },
      onOrderChangesNotificationTap: (orderId) {
        context.push('/restaurant/dashboard/food-order', extra: orderId);
      },
    );

    final reservationSocketService = ref.read(restaurantReservationSocketServiceProvider);
    reservationSocketService.initConnection(
      onNewReservationCallback: (reservation) {
        ref.read(newReservationNotificationProvider.notifier).setNewReservation(reservation);
      },
      onNewReservationNotificationTap: (reservationId) {
        context.push('/restaurant/dashboard/reservation/manage', extra: reservationId);
      },
      onReservationChangesCallback: (reservation) {
        ref
            .read(reservationChangesNotificationProvider.notifier)
            .setReservationChanges(reservation);
      },
      onReservationChangesNotificationTap: (reservationId) {
        context.push('/restaurant/dashboard/reservation/manage', extra: reservationId);
      },
    );
  }

  Future<void> requestNotificationPermissions() async {
    final notificationService = ref.read(localNotificationServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));

      final status = await Permission.notification.status;
      if (status.isGranted) {
        return;
      }

      final bool granted = await notificationService.requestPermissions();

      if (!granted && mounted) {
        showSnackbar(
          context,
          'Notification permissions are required to receive order alerts.',
          state: SnackbarState.success,
          style: ToastificationStyle.fillColored,
        );
      }
    });
  }

  void logout() {
    ref.read(accountViewModelProvider.notifier).signout();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authLocalRepositoryProvider).getUserData();
    bool isLoading = ref.watch(accountViewModelProvider).isSignedOut is LoadingState;

    ref.listen(accountViewModelProvider, (_, next) {
      switch (next.isSignedOut) {
        case SuccessState<bool>():
          ref.invalidate(getSessionDataProvider);
          context.go('/signin');
        case ErrorState():
          ref.invalidate(getSessionDataProvider);
          context.go('/signin');
        case LoadingState():
        case IdleState():
      }
    });

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.neutralColor.shade50,
        surfaceTintColor: AppPallete.neutralColor.shade50,
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: isLoading
                  ? const LoadingIndicatorWidget(size: 24)
                  : Icon(
                      Icons.more_vert,
                      color: AppPallete.neutralColor.shade800,
                    ),
              items: [
                DropdownMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: AppPallete.neutralColor.shade800),
                      const SizedBox(width: 10),
                      Text('Edit Restaurant', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'support',
                  child: Row(
                    children: [
                      Icon(Icons.support_agent_outlined, color: AppPallete.neutralColor.shade800),
                      const SizedBox(width: 10),
                      Text('Support', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_outlined, color: AppPallete.neutralColor.shade800),
                      const SizedBox(width: 10),
                      Text('Log Out', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                switch (value) {
                  case 'edit':
                    context.push('/restaurant/dashboard/update',
                        extra: UserConverter.userToRestaurant(user));
                    break;
                  case 'support':
                    context.push('/customer-support');
                    break;
                  case 'logout':
                    logout();
                    break;
                }
              },
              dropdownStyleData: DropdownStyleData(
                width: 180,
                padding: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                offset: const Offset(0, 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, user.name),
              const SizedBox(height: 24),
              Text(
                'Management Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildManagementOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String restaurantName) {
    return GestureDetector(
      onTap: () {
        context.push('/restaurant/dashboard/outlet');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPallete.primaryColor,
              AppPallete.primaryColor.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppPallete.primaryColor.withAlpha(50),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: Colors.white.withAlpha(200),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Restaurant Dashboard',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome, $restaurantName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your restaurant and monitor activities',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(220),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Jakarta',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOptions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1,
      children: [
        _buildOptionCard(
          context,
          Icons.fastfood,
          'Food Order Management',
          AppPallete.infoColor,
          onTap: () {
            context.push('/restaurant/dashboard/food-order');
          },
        ),
        _buildOptionCard(
          context,
          Icons.calendar_today,
          'Reservation Management',
          AppPallete.warningColor,
          onTap: () {
            context.push('/restaurant/dashboard/reservation');
          },
        ),
        _buildOptionCard(
          context,
          Icons.receipt_long,
          'Transaction Report',
          AppPallete.successColor,
          onTap: () {
            context.push('/restaurant/dashboard/transaction-report');
          },
        ),
        _buildOptionCard(
          context,
          Icons.live_tv,
          'Create Content',
          AppPallete.errorColor,
          onTap: () {
            context.push('/create_content', extra: CreateScreenArgs(
              onPop: (bool value, Object? object) {
                ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
              },
            ));
          },
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppPallete.neutralColor.shade300.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildRecentTransactions(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppPallete.neutralColor.shade300.withAlpha(30),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         FoodOrderItemSummaryWidget(
  //           customerName: 'John Doe',
  //           time: '2 hours ago',
  //           amount: 'Rp 150.000',
  //           status: 'Completed',
  //         ),
  //         const Divider(height: 1),
  //         FoodOrderItemSummaryWidget(
  //           customerName: 'Sarah Smith',
  //           time: '3 hours ago',
  //           amount: 'Rp 95.000',
  //           status: 'Completed',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildUpcomingReservations(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppPallete.neutralColor.shade300.withAlpha(30),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: RecentReservationWidget(),
  //   );
  // }

  // Widget _buildStatistics(BuildContext context) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: AppPallete.neutralColor.shade300.withAlpha(30),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: StatisticSummaryWidget(
  //             title: 'Revenue',
  //             value: 'Rp 2.5M',
  //             increase: '+15%',
  //             icon: Icons.trending_up,
  //             color: AppPallete.successColor,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: AppPallete.neutralColor.shade300.withAlpha(30),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: StatisticSummaryWidget(
  //             title: 'Orders',
  //             value: '45',
  //             increase: '+8%',
  //             icon: Icons.receipt_long,
  //             color: AppPallete.infoColor,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildSocialEngagement(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppPallete.neutralColor.shade300.withAlpha(30),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildEngagementMetric(
  //           context,
  //           icon: Icons.remove_red_eye,
  //           value: '10.5K',
  //           label: 'Views',
  //           color: Colors.purple,
  //         ),
  //         _buildEngagementMetric(
  //           context,
  //           icon: Icons.favorite,
  //           value: '2.3K',
  //           label: 'Likes',
  //           color: AppPallete.errorColor,
  //         ),
  //         _buildEngagementMetric(
  //           context,
  //           icon: Icons.comment,
  //           value: '1.2K',
  //           label: 'Comments',
  //           color: AppPallete.infoColor,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildEngagementMetric(
  //   BuildContext context, {
  //   required IconData icon,
  //   required String value,
  //   required String label,
  //   required Color color,
  // }) {
  //   return Column(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(12),
  //         decoration: BoxDecoration(
  //           color: color.withAlpha(30),
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Icon(icon, size: 24, color: color),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         value,
  //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //               fontWeight: FontWeight.bold,
  //             ),
  //       ),
  //       Text(
  //         label,
  //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //               color: AppPallete.neutralColor.shade600,
  //             ),
  //       ),
  //     ],
  //   );
  // }
}
