import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class RatingStar extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  const RatingStar({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isSelected ? Icons.star_rounded : Icons.star_border_rounded,
          color: isSelected ? AppPallete.primaryColor : Colors.grey.withAlpha(150),
          size: size,
        ),
      ),
    );
  }
}
