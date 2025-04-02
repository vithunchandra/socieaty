import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final double? strokeWidth;
  const LoadingIndicatorWidget({super.key, this.size = 24, this.color, this.strokeWidth});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: strokeWidth ?? (size / 8 > 2 ? (size / 8).floor().toDouble() : 2),
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppPallete.primaryColor),
        ),
      ),
    );
  }
}
