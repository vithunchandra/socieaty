import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;
  final String title;
  final VoidCallback onPressed;
  const CustomErrorWidget({super.key, required this.error, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppPallete.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load $title',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onPressed,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
