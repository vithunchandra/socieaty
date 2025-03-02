import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/restaurant/view/restaurant_navbar.dart';
import 'package:socieaty/shared/provider/navigation_provider.dart';

part 'restaurant_scaffold_with_navbar.g.dart';

@Riverpod(keepAlive: true)
RestaurantScaffoldPageController restaurantScaffoldPageController(Ref ref) {
  return RestaurantScaffoldPageController(ref: ref);
}

class RestaurantScaffoldPageController{
  StatefulNavigationShell? navigationShell;
  final Ref ref;

  RestaurantScaffoldPageController({required this.ref});

  void setNavigationShell(StatefulNavigationShell shell){
    navigationShell = shell;
  }
  
  void pushNewBranch(int index) {
    ref.read(navigationIndexProvider.notifier).addIndex(index);

    goBranch(index);
  }

  void goBranch(int index) {
    navigationShell?.goBranch(
      index,
      initialLocation: index == navigationShell?.currentIndex,
    );
  }

}

class RestaurantScaffoldWithNavbar extends ConsumerStatefulWidget {
  const RestaurantScaffoldWithNavbar({
    super.key,
    required this.navigationShell,
    required this.showNavbar,
  });
  final StatefulNavigationShell navigationShell;
  final bool showNavbar;

  @override
  ConsumerState<RestaurantScaffoldWithNavbar> createState() => _RestaurantScaffoldWithNavbarState();
}

class _RestaurantScaffoldWithNavbarState extends ConsumerState<RestaurantScaffoldWithNavbar> {

  @override
  void initState() {
    super.initState();
    ref.read(restaurantScaffoldPageControllerProvider).setNavigationShell(widget.navigationShell);
  }

  void _pushNewBranch(int index) {
    ref.read(navigationIndexProvider.notifier).addIndex(index);

    _goBranch(index);
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
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
            ? RestaurantNavbar(
                selectedIndex: widget.navigationShell.currentIndex,
                onDestinationSelected: _pushNewBranch,
              )
            : null,
      ),
    );
  }
}
