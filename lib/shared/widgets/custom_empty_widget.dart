import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class CustomEmptyWidget extends StatelessWidget {
  final IconData icon;
  final String description;
  final String title;
  const CustomEmptyWidget({super.key, required this.description, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppPallete.neutralColor.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
