import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/home/customer/provider/all_post_provider.dart';
import 'package:socieaty/features/home/customer/viewmodel/home_screen_view_model.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/view/post_view.dart';
import 'package:socieaty/shared/widgets/custom_scroll_physics.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Post>> postsProviderResult = ref.watch(allPostProvider);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            switch (postsProviderResult) {
              AsyncData(:final value) => PageView(
                  controller: _pageController,
                  physics: const CustomPageViewScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    ref.read(homeScreenViewModelProvider.notifier).setCurrentPostId(value[index].id);
                  },
                  children: [...value.map((post) => PostView(post: post, userId: ref.watch(authLocalRepositoryProvider).getUserData()!.id))],
                ),
              AsyncError(:final error, :final stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Stacktrace: $stackTrace', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              _ => const LoadingIndicatorWidget(),
            },
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    TextButton(onPressed: () {}, child: Text("FYP")),
                    TextButton(onPressed: () {}, child: Text("Customer")),
                    TextButton(onPressed: () {}, child: Text("Restaurant")),
                    Expanded(child: SizedBox()),
                    IconButton(
                      onPressed: () {
                        ref.invalidate(allPostProvider);
                      },
                      icon: Icon(Icons.live_tv),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
