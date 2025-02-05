import 'package:flutter/material.dart';

class BannerImageWidget extends StatelessWidget {
  final String image;
  const BannerImageWidget({super.key, required this.image});

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
