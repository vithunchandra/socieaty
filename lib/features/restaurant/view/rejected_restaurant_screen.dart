import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/account/customer/viewmodel/account_view_model.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food-order/restaurant/socket/restaurant_socket_service.dart';
import 'package:socieaty/shared/view_state.dart';

class RejectedRestaurantScreen extends ConsumerStatefulWidget {
  const RejectedRestaurantScreen({super.key});

  @override
  ConsumerState<RejectedRestaurantScreen> createState() => _RejectedRestaurantScreenState();
}

class _RejectedRestaurantScreenState extends ConsumerState<RejectedRestaurantScreen> {
  void handleLogout() {
    ref.read(restaurantSocketServiceProvider).disconnect();
    ref.invalidate(getSessionDataProvider);
    context.go('/landing');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenSize.height - 60, // Accounting for SafeArea padding
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(theme),
                  SizedBox(height: screenSize.height * 0.03),
                  _buildIllustration(screenSize),
                  SizedBox(height: screenSize.height * 0.03),
                  _buildRejectionInfo(theme),
                  SizedBox(height: screenSize.height * 0.05),
                  _buildButtonActions(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Pendaftaran Ditolak',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppPallete.errorColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppPallete.errorColor.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppPallete.errorColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Tidak Disetujui',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppPallete.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.25,
      width: screenSize.width * 0.5,
      child: CircleAvatar(
        radius: screenSize.width * 0.25,
        backgroundColor: AppPallete.errorColor.withAlpha(30),
        child: Icon(
          Icons.close_rounded,
          size: screenSize.width * 0.25,
          color: AppPallete.errorColor,
        ),
      ),
    );
  }

  Widget _buildRejectionInfo(ThemeData theme) {
    return Text(
      'Pendaftaran restoran Anda ditolak',
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildButtonActions(BuildContext context, ThemeData theme) {
    final user = ref.read(authLocalRepositoryProvider).getUserData();
    return Column(
      children: [
        FilledButton(
          onPressed: () {
            context.go('/restaurant/rejected/update', extra: UserConverter.userToRestaurant(user!));
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Perbarui Data Restoran',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            ref.read(accountViewModelProvider.notifier).signout();
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppPallete.neutralColor[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Keluar',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppPallete.neutralColor[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
