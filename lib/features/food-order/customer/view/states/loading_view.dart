import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppPallete.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading order details...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppPallete.neutralColor.shade700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we fetch your order information',
            style: TextStyle(
              fontSize: 14,
              color: AppPallete.neutralColor.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
