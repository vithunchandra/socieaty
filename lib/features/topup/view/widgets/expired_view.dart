import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class TopupExpiredView extends StatelessWidget {
  const TopupExpiredView({super.key});

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
              Icons.timer_off_outlined,
              size: 72,
              color: AppPallete.warningColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Pembayaran Kadaluarsa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPallete.neutralColor.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Batas waktu pembayaran telah berakhir. Silakan buat transaksi topup baru.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppPallete.neutralColor.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  color: Colors.white,
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
