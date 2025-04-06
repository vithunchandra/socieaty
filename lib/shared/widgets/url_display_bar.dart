import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class TopupUrlDisplayBar extends StatelessWidget {
  final String url;

  const TopupUrlDisplayBar({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppPallete.neutralColor.shade100,
      child: Text(
        url,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppPallete.neutralColor.shade700,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
