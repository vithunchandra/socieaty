import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/restaurant/view/restaurant_reservation_home_screen.dart';
import 'package:socieaty/features/restaurant/provider/get_restaurant_reservation_config_provider.dart';
import 'package:socieaty/features/restaurant/view/create_reservation_config_screen.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class ReservationNavigatorScreen extends ConsumerWidget {
  const ReservationNavigatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authLocalRepositoryProvider).getUserData();
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go('/signin');
            },
            child: const Text('Sign in'),
          ),
        ),
      );
    }
    final reservationConfig = ref.watch(
      getRestaurantReservationConfigProvider(currentUser.restaurantData!.id),
    );
    return reservationConfig.when(
      data: (data) {
        if (data == null) {
          return CreateReservationConfigScreen();
        } else {
          return const RestaurantReservationHomeScreen();
        }
      },
      error: (error, stack) {
        return CustomErrorWidget(
          error: error.toString(),
          title: "Reservation Config",
          onPressed: () {
            ref.invalidate(getRestaurantReservationConfigProvider(currentUser.restaurantData!.id));
          },
        );
      },
      loading: () => const Scaffold(
        body: LoadingIndicatorWidget(),
      ),
    );
  }
}
