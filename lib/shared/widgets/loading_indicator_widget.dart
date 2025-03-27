import 'package:flutter/material.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final double? size;
  const LoadingIndicatorWidget({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
