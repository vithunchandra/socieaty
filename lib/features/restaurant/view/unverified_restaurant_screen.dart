import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class UnverifiedRestaurantScreen extends StatelessWidget {
  const UnverifiedRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(theme),
              SizedBox(height: screenSize.height * 0.05),
              _buildIllustration(screenSize),
              SizedBox(height: screenSize.height * 0.05),
              _buildStatusInfo(theme),
              const SizedBox(height: 16),
              _buildDescription(theme),
              const Spacer(),
              _buildRefreshButton(context, theme),
            ],
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
    return Container(
      height: screenSize.height * 0.25,
      width: double.infinity,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: screenSize.width * 0.25,
            backgroundColor: AppPallete.primaryColor[100],
          ),
          Icon(
            Icons.restaurant_rounded,
            size: screenSize.width * 0.25,
            color: AppPallete.primaryColor,
          ),
          Positioned(
            right: screenSize.width * 0.15,
            bottom: screenSize.height * 0.02,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppPallete.neutralColor[300]!,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                color: AppPallete.warningColor,
                size: screenSize.width * 0.08,
              ),
            ),
          ),
        ],
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

  Widget _buildRefreshButton(BuildContext context, ThemeData theme) {
    return FilledButton(
      onPressed: () {
        // Refresh verification status implementation
      },
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh_rounded,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            'Perbarui Status',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
