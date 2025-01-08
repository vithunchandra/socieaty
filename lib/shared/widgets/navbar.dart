import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class Navbar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const Navbar({
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
          BoxShadow(color: AppPallete.neutralColor.withValues(alpha: 0.5), blurRadius: 4),
        ],
      ),
      child: NavigationBar(
        height: screenHeight * 0.09,
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 3,
        destinations: [
          NavigationDestination(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            label: 'Search',
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
          ),
          NavigationDestination(
            icon: GestureDetector(
              onTap: () {
                context.push('/create_post');
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: SizedBox(
                  width: 55,
                  height: 45,
                  child: Card(
                    color: AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2.0,
                    child: Icon(
                      Icons.add,
                      color: AppPallete.neutralColor.shade50,
                    ),
                  ),
                ),
              ),
            ),
            label: "",
          ),
          NavigationDestination(
            label: 'Shop',
            icon: Icon(Icons.shop_outlined),
            selectedIcon: Icon(Icons.shop),
          ),
          NavigationDestination(
            label: 'Account',
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
          )
        ],
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
