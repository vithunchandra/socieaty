import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/livestream/model/live_room.dart';
import 'package:socieaty/features/livestream/provider/livestream_room_provider.dart';
import 'package:socieaty/shared/provider/navigation_provider.dart';
import 'package:socieaty/features/livestream/view/livestream_widget.dart';
import 'package:socieaty/shared/widgets/custom_scroll_physics.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class LivestreamHomeScreen extends ConsumerStatefulWidget {
  const LivestreamHomeScreen({super.key});

  @override
  ConsumerState<LivestreamHomeScreen> createState() => _LivestreamHomeScreenState();
}

class _LivestreamHomeScreenState extends ConsumerState<LivestreamHomeScreen> {
  final PageController _pageController = PageController();
  List<LiveRoom> _rooms = [];
  bool _isLoading = false;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isLoading = ref.watch(getLivestreamRoomsProvider) is AsyncLoading;
    ref.listen(getLivestreamRoomsProvider, (previous, next) {
      switch (next) {
        case AsyncData(value: final value):
          _rooms = value;
          debugPrint('rooms: $_rooms');
        case AsyncError(error: final error):
          showSnackbar(context, error.toString(), isError: true);
      }
    });

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
        body: _isLoading
            ? const LoadingIndicatorWidget()
            : _rooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cancel, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak Ada Livestream',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Periksa Kembali Setelah Beberapa Saat',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 200,
                          child: FilledButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Kembali',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      // PageView for Livestreams
                      PageView.builder(
                        itemCount: _rooms.length,
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        physics: CustomPageViewScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final liveRoom = _rooms[index];
                          return LivestreamWidget(
                            liveRoom,
                            key: UniqueKey(),
                          );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}
