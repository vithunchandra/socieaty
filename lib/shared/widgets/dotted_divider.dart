import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class DottedDivider extends StatelessWidget {
  final Color? color;
  final double height;
  final double width;
  final double strokeWidth;
  final double gap;
  final Widget? label;

  const DottedDivider({
    super.key,
    this.color,
    this.height = 1,
    this.width = 5,
    this.strokeWidth = 1,
    this.gap = 3,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomPaint(
                painter: _DottedLinePainter(
                  color: color ?? AppPallete.primaryColor,
                  strokeWidth: strokeWidth,
                  width: width,
                  gap: gap,
                ),
                child: SizedBox(height: height),
              ),
            ),
          ],
        ),
        if (label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: label,
          ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double width;
  final double gap;

  _DottedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.width,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startY = size.height / 2;
    var currentX = 0.0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, startY),
        Offset(currentX + width, startY),
        paint,
      );
      currentX += width + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      width != oldDelegate.width ||
      gap != oldDelegate.gap;
}