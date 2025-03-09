import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class NotTrackedView extends StatelessWidget {
  final VoidCallback onBackPressed;

  const NotTrackedView({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'Order Not Being Tracked',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppPallete.neutralColor.shade900,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'This order is no longer being tracked. It may have been completed, canceled, or expired.',
              style: TextStyle(
                fontSize: 14,
                color: AppPallete.neutralColor.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
