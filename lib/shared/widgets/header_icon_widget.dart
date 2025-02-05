import 'package:flutter/material.dart';

class HeaderIconWidget extends StatelessWidget {
  final bool isScrollCompleted;
  final IconData icon;
  final VoidCallback onPressed;
  const HeaderIconWidget({
    super.key,
    required this.isScrollCompleted,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: isScrollCompleted
          ? null
          : BoxDecoration(
              color: Colors.black.withAlpha(128),
              shape: BoxShape.circle,
            ),
      child: IconButton(
        icon: isScrollCompleted ? Icon(icon, color: Colors.black, size: 20) : Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
