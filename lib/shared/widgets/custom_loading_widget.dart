import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  const CustomLoadingWidget({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingIndicatorWidget(size: 36),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppPallete.neutralColor.shade700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
