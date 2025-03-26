import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class GenericErrorView extends StatelessWidget {
  final VoidCallback onBackPressed;

  const GenericErrorView({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 72,
              color: AppPallete.errorColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Dapat Memuat Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan saat mencoba memuat data reservasi. Silakan coba lagi nanti.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPallete.neutralColor.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
