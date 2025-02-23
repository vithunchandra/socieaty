import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/features/home/customer/provider/all_post_provider.dart';
import 'package:socieaty/shared/provider/navigation_provider.dart';
import 'package:socieaty/features/customer/view/customer_navbar.dart';

class CustomerScaffoldWithNavbar extends ConsumerStatefulWidget {
  const CustomerScaffoldWithNavbar({
    super.key,
    required this.navigationShell,
    required this.showNavbar,
  });
  final StatefulNavigationShell navigationShell;
  final bool showNavbar;

  @override
  ConsumerState<CustomerScaffoldWithNavbar> createState() => _CustomerScaffoldWithNavbarState();
}

class _CustomerScaffoldWithNavbarState extends ConsumerState<CustomerScaffoldWithNavbar> {
  void _pushNewBranch(int index) {
    ref.read(navigationIndexProvider.notifier).addIndex(index);

    _goBranch(index);
  }

  void _goBranch(int index) {
    if (index == 0 || index == 1) {
      ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
    } else {
      ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
    }
    if (index == 2) {
      context.push('/create_content');
    } else if (index == 1) {
      context.push('/livestreams');
    } else {
      if (index == 0 && widget.navigationShell.currentIndex == 0) {
        ref.invalidate(allPostProvider);
      }
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: ref.watch(navigationIndexProvider).length < 2,
      onPopInvokedWithResult: (didPop, object) {
        if (didPop) return;

        if (ref.watch(navigationIndexProvider).length > 1) {
          ref.read(navigationIndexProvider.notifier).removeLastIndex();
          final previousIndex = ref.watch(navigationIndexProvider).last;
          return _goBranch(previousIndex);
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: widget.showNavbar
            ? CustomerNavbar(
                selectedIndex: widget.navigationShell.currentIndex,
                onDestinationSelected: _pushNewBranch,
              )
            : null,
      ),
    );
  }
}
