import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/authentication/provider/get_user_data_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/customer/view/current_customer_profile_screen.dart';
import 'package:socieaty/features/customer/view/others_customer_profile_screen.dart';
import 'package:socieaty/features/restaurant/view/owner_outlet_screen.dart';
import 'package:socieaty/features/restaurant/view/other_outlet_screen.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class ProfileLoaderScreen extends ConsumerStatefulWidget {
  final String userId;
  const ProfileLoaderScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileLoaderScreen> createState() => _ProfileLoaderScreenState();
}

class _ProfileLoaderScreenState extends ConsumerState<ProfileLoaderScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(getUserDataProvider(widget.userId));
    final currentUser = ref.watch(authLocalRepositoryProvider).getUserData();
    return userAsyncValue.when(
      data: (userData) {
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
        if (userData.role == UserRole.customer && userData.customerData != null) {
          if (userData.id == currentUser.id) {
            return CurrentCustomerProfileScreen(user: UserConverter.userToCustomer(userData));
          } else {
            return OtherCustomerProfileScreen(user: UserConverter.userToCustomer(userData));
          }
        } else if (userData.role == UserRole.restaurant && userData.restaurantData != null) {
          if (userData.id == currentUser.id) {
            return OwnerOutletScreen(restaurant: UserConverter.userToRestaurant(userData));
          } else {
            return OtherOutletScreen(restaurant: UserConverter.userToRestaurant(userData));
          }
        } else {
          if (userData.role == UserRole.customer || userData.role == UserRole.admin) {
            return OtherCustomerProfileScreen(user: UserConverter.userToCustomer(userData));
          } else {
            return OtherOutletScreen(restaurant: UserConverter.userToRestaurant(userData));
          }
        }
      },
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: CustomErrorWidget(
            error: error.toString(),
            title: "Profile",
            onPressed: () {
              ref.invalidate(getUserDataProvider(widget.userId));
            },
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: LoadingIndicatorWidget(size: 36),
      ),
    );
  }
}
