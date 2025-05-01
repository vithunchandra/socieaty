import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/account/customer/viewmodel/account_view_model.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/food-order/restaurant/socket/restaurant_socket_service.dart';
import 'package:socieaty/shared/view_state.dart';

class UnverifiedRestaurantScreen extends ConsumerStatefulWidget {
  const UnverifiedRestaurantScreen({super.key});

  @override
  ConsumerState<UnverifiedRestaurantScreen> createState() => _UnverifiedRestaurantScreenState();
}

class _UnverifiedRestaurantScreenState extends ConsumerState<UnverifiedRestaurantScreen> {
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
                children: [
                  _buildHeader(theme),
                  SizedBox(height: screenSize.height * 0.03),
                  _buildIllustration(screenSize),
                  SizedBox(height: screenSize.height * 0.03),
                  _buildStatusInfo(theme),
                  const SizedBox(height: 16),
                  _buildDescription(theme),
                  const Expanded(child: SizedBox()),
                  _buildLogoutButton(context, theme),
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
          'Verifikasi Sedang Berlangsung',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppPallete.warningColor.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppPallete.warningColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Menunggu Persetujuan',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppPallete.warningColor,
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
        backgroundColor: AppPallete.primaryColor[100]!.withAlpha(128),
        child: Icon(
          Icons.hourglass_top_rounded,
          color: AppPallete.warningColor,
          size: screenSize.width * 0.25,
        ),
      ),
    );
  }

  Widget _buildStatusInfo(ThemeData theme) {
    return Text(
      'Restoran Anda sedang dalam peninjauan',
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      'Tim kami sedang meninjau informasi restoran Anda. Proses ini biasanya membutuhkan waktu 1-3 hari kerja. Anda akan menerima notifikasi setelah akun Anda terverifikasi.',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppPallete.neutralColor[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return FilledButton(
      onPressed: () {
        ref.read(accountViewModelProvider.notifier).signout();
      },
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(
        'Kembali ke halaman login',
        style: theme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
