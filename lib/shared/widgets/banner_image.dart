import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final String image;
  const BannerImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Image.asset(image),
        ),
      ),
    );
  }
}
