import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class TopupFailedView extends StatelessWidget {
  final VoidCallback onRetry;

  const TopupFailedView({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 72,
              color: AppPallete.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Pembayaran Gagal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPallete.neutralColor.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maaf, pembayaran Anda gagal diproses. Silakan coba lagi atau gunakan metode pembayaran lain.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppPallete.neutralColor.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Kembali',
                style: TextStyle(
                  color: AppPallete.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
