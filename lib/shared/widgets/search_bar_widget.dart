import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String hintText;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppPallete.neutralColor.shade400.withAlpha(128),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: AppPallete.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hintText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.map,
              color: AppPallete.primaryColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
