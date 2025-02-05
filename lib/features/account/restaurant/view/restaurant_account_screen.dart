import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/features/account/customer/viewmodel/account_view_model.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class RestaurantAccountScreen extends ConsumerStatefulWidget {
  const RestaurantAccountScreen({super.key});

  @override
  ConsumerState<RestaurantAccountScreen> createState() => _RestaurantAccountScreenState();
}

class _RestaurantAccountScreenState extends ConsumerState<RestaurantAccountScreen> {
  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(accountViewModelProvider).isSignedOut is LoadingState ? true : false;

    ref.listen(accountViewModelProvider, (_, next) {
      switch (next.isSignedOut) {
        case SuccessState<bool>():
          ref.invalidate(getSessionDataProvider);
          context.go('/landing');
        case ErrorState():
          ref.invalidate(getSessionDataProvider);
          context.go('/landing');
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
