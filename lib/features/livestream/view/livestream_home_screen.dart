import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/app_theme.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/shared/provider/navigation_provider.dart';
import 'package:socieaty/features/livestream/view/livestream_view.dart';
import 'package:socieaty/shared/widgets/custom_scroll_physics.dart';

class LivestreamHomeScreen extends ConsumerStatefulWidget {
  const LivestreamHomeScreen({super.key});

  @override
  ConsumerState<LivestreamHomeScreen> createState() => _LivestreamHomeScreenState();
}

class _LivestreamHomeScreenState extends ConsumerState<LivestreamHomeScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool value, Object? result) {
        if (ref.watch(navigationIndexProvider).length > 1) {
          ref.read(navigationIndexProvider.notifier).removeLastIndex();
          final previousIndex = ref.watch(navigationIndexProvider).last;
          if (previousIndex == 3 || previousIndex == 4) {
            ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // PageView for Livestreams
            PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: CustomPageViewScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                LivestreamView(),
                LivestreamView(),
                LivestreamView(),
                LivestreamView(),
                LivestreamView(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
