import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class RestaurantNavbar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const RestaurantNavbar({
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
            label: 'Dashboard',
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(
              Icons.dashboard,
              color: AppPallete.primaryColor,
            ),
          ),
          NavigationDestination(
            label: 'Aktivitas',
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(
              Icons.history,
              color: AppPallete.primaryColor,
            ),
          ),
          NavigationDestination(
            label: 'Akun',
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: AppPallete.primaryColor,
            ),
          )
        ],
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
