import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final double size;
  final Color? color;
  const LoadingIndicatorWidget({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    debugPrint('size nya: $size');

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppPallete.primaryColor),
        ),
      ),
    );
  }
}
