import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class TopupLoadingView extends StatelessWidget {
  const TopupLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppPallete.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat data pembayaran...',
              style: TextStyle(
                color: AppPallete.neutralColor.shade800,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}
