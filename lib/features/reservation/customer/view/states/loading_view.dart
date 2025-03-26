import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppPallete.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Memuat Data Reservasi...',
            style: TextStyle(
              fontSize: 16,
              color: AppPallete.neutralColor.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
