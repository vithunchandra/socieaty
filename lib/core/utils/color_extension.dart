import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// Extension method to safely replace deprecated withOpacity with withAlpha
  Color withOpacitySafe(double opacity) {
    return withAlpha((opacity * 255).round());
  }
} 