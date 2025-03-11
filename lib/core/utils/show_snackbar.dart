import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showSnackbar(
  BuildContext? context,
  String content, {
  SnackbarStates state = SnackbarStates.success,
  ToastificationStyle? style,
}) {
  final colors = {
    'success': Color(0xFFEB7317),
    'error': Colors.red.shade800,
    'info': Color(0xFF0F8BFF),
    'warning': Color(0xFFF19809),
  };

  final type = {
    'success': ToastificationType.success,
    'error': ToastificationType.error,
    'info': ToastificationType.info,
    'warning': ToastificationType.warning,
  };

  final defaultStyle = {
    'success': ToastificationStyle.flatColored,
    'error': ToastificationStyle.fillColored,
    'info': ToastificationStyle.flatColored,
    'warning': ToastificationStyle.flatColored,
  };

  toastification.show(
    context: context,
    type: type[state.name],
    style: style ?? defaultStyle[state.name],
    title: Text(content),
    alignment: Alignment.bottomCenter,
    autoCloseDuration: const Duration(seconds: 5),
    primaryColor: colors[state.name],
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    dragToClose: true,
    showProgressBar: false,
    applyBlurEffect: true,
    closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
  );
}

enum SnackbarStates {
  success,
  error,
  info,
  warning,
}
