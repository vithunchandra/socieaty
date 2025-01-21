import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/app_theme.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/features/livestream/view/setup_livestream_screen.dart';
import 'package:socieaty/features/post/post/view/create_post_screen.dart';
import 'package:socieaty/shared/provider/navigation_provider.dart';
import 'package:socieaty/shared/widgets/custom_scroll_physics.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
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
          if (previousIndex == 0 || previousIndex == 1) {
            ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
          } else if (previousIndex == 3 || previousIndex == 4) {
            ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
          }
        }
      },
      child: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: CustomPageViewScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
            if (currentPage == 0) {
              ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.lightTheme);
            } else {
              ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
            }
          });
        },
        children: [
          CreatePostScreen(key: const PageStorageKey('create_post')),
          SetupLiveStreamScreen(key: const PageStorageKey('setup_livestream')),
        ],
      ),
    );
  }
}
