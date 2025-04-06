import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TopupWebViewNavigationBar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final WebViewController controller;

  const TopupWebViewNavigationBar({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: canGoBack ? AppPallete.primaryColor : AppPallete.neutralColor.shade300,
              size: 20,
            ),
            onPressed: canGoBack ? () => controller.goBack() : null,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppPallete.primaryColor,
              size: 24,
            ),
            onPressed: () => controller.reload(),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: canGoForward ? AppPallete.primaryColor : AppPallete.neutralColor.shade300,
              size: 20,
            ),
            onPressed: canGoForward ? () => controller.goForward() : null,
          ),
        ],
      ),
    );
  }
}
