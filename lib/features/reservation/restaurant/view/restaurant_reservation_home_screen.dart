import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/restaurant/viewmodel/restaurant_reservation_home_view_model.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/provider/get_restaurant_reservation_config_provider.dart';
import 'package:socieaty/features/restaurant/view/create_reservation_config_screen.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'dart:async';

class RestaurantReservationHomeScreen extends ConsumerStatefulWidget {
  const RestaurantReservationHomeScreen({super.key});

  @override
  ConsumerState<RestaurantReservationHomeScreen> createState() =>
      _RestaurantReservationHomeScreenState();
}

class _RestaurantReservationHomeScreenState extends ConsumerState<RestaurantReservationHomeScreen> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleReservationAvailability(bool value) {
    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(restaurantReservationHomeViewModelProvider.notifier)
          .toggleReservationAvailability(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurant =
        UserConverter.userToRestaurant(ref.watch(authLocalRepositoryProvider).getUserData()!);
    final reservationConfig =
        ref.watch(getRestaurantReservationConfigProvider(restaurant.restaurantData.id));

    debugPrint(restaurant.restaurantData.isReservationAvailable.toString());

    ref.listen(restaurantReservationHomeViewModelProvider, (previous, next) {
      switch (next.toggleReservationState) {
        case SuccessState():
          showSnackbar(context, "Berhasil mengubah status reservasi");
        case ErrorState():
          showSnackbar(context, "Gagal mengubah status reservasi");
        default:
          break;
      }
      setState(() {});
    });

    return reservationConfig.when(
      data: (config) {
        if (config == null) {
          return const CreateReservationConfigScreen();
        } else {
          return Scaffold(
            backgroundColor: AppPallete.neutralColor.shade50,
            appBar: AppBar(
              title: Text(
                'Reservasi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    context.push('/restaurant/dashboard/reservation/config/update', extra: config);
                  },
                  color: AppPallete.primaryColor,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReservationToggleCard(restaurant),
                  const SizedBox(height: 16),
                  _buildTodayReservationsSection(config),
                  const SizedBox(height: 16),
                  _buildConfigurationSection(config),
                  const SizedBox(height: 72),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                context.push('/restaurant/dashboard/reservation/manage');
              },
              backgroundColor: AppPallete.primaryColor,
              icon: const Icon(Icons.notifications),
              label: const Text('Kelola'),
            ),
          );
        }
      },
      error: (error, stack) {
        return Scaffold(
          body: CustomErrorWidget(
            error: error.toString(),
            title: 'Konfigurasi Reservasi',
            onPressed: () {
              ref.invalidate(getRestaurantReservationConfigProvider(restaurant.id));
            },
          ),
        );
      },
      loading: () => Scaffold(
        body: LoadingIndicatorWidget(size: 36),
      ),
    );
  }

  Widget _buildReservationToggleCard(SocieatyRestaurant restaurant) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Layanan Reservasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.restaurantData.isReservationAvailable
                      ? 'Restoran Anda saat ini menerima reservasi'
                      : 'Restoran Anda saat ini tidak menerima reservasi',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPallete.neutralColor.shade500,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: restaurant.restaurantData.isReservationAvailable,
            onChanged: (value) {
              _toggleReservationAvailability(value);
            },
            activeColor: AppPallete.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReservationsSection(ReservationConfig reservationConfig) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withAlpha(25),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: AppPallete.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reservasi Hari Ini',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppPallete.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Sample reservation items
          _buildReservationItem(
            time: '09:30',
            customerName: 'John Doe',
            peopleCount: 2,
            status: 'Confirmed',
          ),
          Divider(height: 1, color: AppPallete.neutralColor.shade200),
          _buildReservationItem(
            time: '13:00',
            customerName: 'Jane Smith',
            peopleCount: 4,
            status: 'Pending',
          ),
          Divider(height: 1, color: AppPallete.neutralColor.shade200),
          _buildReservationItem(
            time: '19:30',
            customerName: 'Robert Johnson',
            peopleCount: 6,
            status: 'Confirmed',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to all reservations screen
                  context.push('/restaurant/dashboard/reservation/view', extra: reservationConfig);
                },
                child: Text(
                  'Lihat Semua Reservasi',
                  style: TextStyle(
                    color: AppPallete.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationItem({
    required String time,
    required String customerName,
    required int peopleCount,
    required String status,
  }) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = AppPallete.successColor;
        break;
      case 'pending':
        statusColor = AppPallete.warningColor;
        break;
      case 'cancelled':
        statusColor = AppPallete.errorColor;
        break;
      default:
        statusColor = AppPallete.infoColor;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  color: AppPallete.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style:
                      Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$peopleCount orang',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPallete.neutralColor.shade500,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection(ReservationConfig reservationConfig) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konfigurasi Saat Ini',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildConfigItem(
            icon: Icons.people,
            title: 'Maksimum Orang',
            value: '${reservationConfig.maxPerson} per reservasi',
          ),
          _buildConfigItem(
            icon: Icons.attach_money,
            title: 'Minimum Biaya',
            value: 'Rp ${reservationConfig.minCostPerPerson} per orang',
          ),
          _buildConfigItem(
            icon: Icons.timer,
            title: 'Batas Waktu',
            value: '${reservationConfig.timeLimit} jam',
          ),
          _buildConfigItem(
            icon: Icons.category,
            title: 'Fasilitas',
            value: reservationConfig.facilities.join(', '),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppPallete.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPallete.neutralColor.shade500,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
