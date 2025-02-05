import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class CustomCircleAvatarWidget extends StatelessWidget {
  final double radius;
  final String imageUrl;
  const CustomCircleAvatarWidget({super.key, required this.radius, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPallete.neutralColor.shade50,
      borderRadius: BorderRadius.circular(25),
      elevation: 2.0,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(imageUrl),
      ),
    );
  }
}
