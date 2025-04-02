import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/features/account/customer/viewmodel/account_view_model.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/food-order/restaurant/socket/restaurant_socket_service.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class RestaurantAccountScreen extends ConsumerStatefulWidget {
  const RestaurantAccountScreen({super.key});

  @override
  ConsumerState<RestaurantAccountScreen> createState() => _RestaurantAccountScreenState();
}

class _RestaurantAccountScreenState extends ConsumerState<RestaurantAccountScreen> {
  void disconnectSocket() {
    ref.read(restaurantSocketServiceProvider).disconnect();
  }

  void handleLogout() {
    disconnectSocket();
    ref.invalidate(getSessionDataProvider);
    context.go('/landing');
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(accountViewModelProvider).isSignedOut is LoadingState ? true : false;

    ref.listen(accountViewModelProvider, (_, next) {
      switch (next.isSignedOut) {
        case SuccessState<bool>():
          handleLogout();
        case ErrorState():
          handleLogout();

        case LoadingState():
        case IdleState():
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Account'),
      ),
      body: isLoading
          ? const LoadingIndicatorWidget(size: 32)
          : Center(
              child: FilledButton(
                onPressed: () {
                  ref.read(accountViewModelProvider.notifier).signout();
                },
                child: const Text("Logout"),
              ),
            ),
    );
  }
}
