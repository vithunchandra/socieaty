import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class CustomerNavbar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomerNavbar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: AppPallete.neutralColor.withAlpha(128), blurRadius: 4),
        ],
      ),
      child: NavigationBar(
        height: screenHeight * 0.075,
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            // Set overlayColor to transparent for all states
            return Colors.transparent;
          },
        ),
        elevation: 3,
        destinations: [
          NavigationDestination(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home,
              color: AppPallete.primaryColor,
            ),
          ),
          NavigationDestination(
            label: 'Live',
            icon: Icon(Icons.live_tv_outlined),
            selectedIcon: Icon(
              Icons.live_tv,
              color: AppPallete.primaryColor,
            ),
          ),
          Center(
            child: IconButton.filled(
              onPressed: () {
                onDestinationSelected(2);
              },
              icon: Icon(
                Icons.add,
                color: AppPallete.neutralColor.shade50,
              ),
            ),
          ),
          NavigationDestination(
            label: 'Shop',
            icon: Icon(Icons.shop_outlined),
            selectedIcon: Icon(
              Icons.shop,
              color: AppPallete.primaryColor,
            ),
          ),
          NavigationDestination(
            label: 'Account',
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(
              Icons.account_circle,
              color: AppPallete.primaryColor,
            ),
          )
        ],
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
