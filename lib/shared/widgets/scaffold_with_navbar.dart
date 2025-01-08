import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/shared/widgets/navbar.dart';

class ScaffoldWithNavbar extends ConsumerStatefulWidget {
  const ScaffoldWithNavbar({
    super.key,
    required this.navigationShell,
    required this.showNavbar,
  });
  final StatefulNavigationShell navigationShell;
  final bool showNavbar;

  @override
  ConsumerState<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends ConsumerState<ScaffoldWithNavbar> {
  final List<int> indexHistory = [0];

  void _pushNewBranch(int index) {
    setState(() {
      indexHistory.add(index);
    });

    _goBranch(index);
  }

  void _goBranch(int index) {
    if (index == 0) {
      ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
    } else {
      ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: indexHistory.length < 2,
      onPopInvokedWithResult: (didPop, object) {
        if (didPop) return;

        if (indexHistory.length > 1) {
          indexHistory.removeLast();
          final previousIndex = indexHistory.last;
          return _goBranch(previousIndex);
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: widget.showNavbar
            ? Navbar(
                selectedIndex: widget.navigationShell.currentIndex,
                onDestinationSelected: _pushNewBranch,
              )
            : null,
      ),
    );
  }
}
