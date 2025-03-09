import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/features/account/customer/viewmodel/account_view_model.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/transaction/restaurant/socket/restaurant_socket_service.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class RestaurantAccountScreen extends ConsumerStatefulWidget {
  const RestaurantAccountScreen({super.key});

  @override
  ConsumerState<RestaurantAccountScreen> createState() => _RestaurantAccountScreenState();
}

class _RestaurantAccountScreenState extends ConsumerState<RestaurantAccountScreen> {
  void disconnectSocket() {
    // Disconnect the socket when logging out
    ref.read(restaurantSocketServiceProvider).disconnect();
  }

  void handleLogout() {
    // Disconnect socket before navigating away
    disconnectSocket();
    ref.invalidate(getSessionDataProvider);

    // Navigate to login screen (implement your navigation logic here)
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
          ? LoadingIndicatorWidget()
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
