import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class RejectedRestaurantScreen extends StatelessWidget {
  final String? rejectionReason;
  const RejectedRestaurantScreen({super.key, this.rejectionReason});

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
              _buildRejectionInfo(theme),
              const SizedBox(height: 16),
              _buildRejectionReason(theme),
              const SizedBox(height: 24),
              _buildDescription(theme),
              const Spacer(),
              _buildReapplyButton(context, theme),
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
    return Container(
      height: screenSize.height * 0.25,
      width: double.infinity,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: screenSize.width * 0.25,
            backgroundColor: AppPallete.errorColor.withAlpha(30),
          ),
          Icon(
            Icons.restaurant_rounded,
            size: screenSize.width * 0.25,
            color: AppPallete.neutralColor[400],
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
                Icons.close_rounded,
                color: AppPallete.errorColor,
                size: screenSize.width * 0.08,
              ),
            ),
          ),
        ],
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

  Widget _buildRejectionReason(ThemeData theme) {
    if (rejectionReason == null || rejectionReason!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.neutralColor[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.neutralColor[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alasan Penolakan:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rejectionReason ?? '',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      'Anda dapat mengajukan pendaftaran ulang dengan memperbarui informasi restoran Anda sesuai dengan pedoman kami. Pastikan semua dokumen dan informasi yang diperlukan sudah lengkap dan akurat.',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppPallete.neutralColor[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildReapplyButton(BuildContext context, ThemeData theme) {
    return FilledButton(
      onPressed: () {
        // Reapply implementation
      },
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppPallete.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restart_alt_rounded,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            'Daftar Ulang',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
