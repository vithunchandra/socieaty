import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/post/post/provider/paginate_posts_provider.dart';
import 'package:socieaty/features/post/post/view/post_carousel_item.dart';
import 'package:socieaty/features/restaurant_menu/provider/get_food_menu_provider.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/view/food_menu_item_view_widget.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';

class OutletHomeWidget extends ConsumerStatefulWidget {
  const OutletHomeWidget({super.key});

  @override
  ConsumerState<OutletHomeWidget> createState() => _OutletHomeWidgetState();
}

class _OutletHomeWidgetState extends ConsumerState<OutletHomeWidget> {
  final carouselController = CarouselController();
  bool _hasSetInitialPage = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final restaurantMenus = ref.watch(getFoodMenusProvider(MenuFilterFormState()));
    final posts = ref.watch(paginatePostsProvider(offset: 0, limit: 5));

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Menu", style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(width: 12),
                  Expanded(
                    child: Divider(
                      color: AppPallete.neutralColor,
                      thickness: 0.5,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 12),
            restaurantMenus.when(data: (data) {
              final partialData = data.take(5).toList();
              return ExpandableCarousel(
                options: ExpandableCarouselOptions(
                  scrollDirection: Axis.horizontal,
                  pageSnapping: true,
                  viewportFraction: 1.0,
                  showIndicator: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 500),
                  autoPlayCurve: Curves.easeInOut,
                  enableInfiniteScroll: true,
                ),
                items: partialData.map((menu) {
                  return GestureDetector(
                    onTap: () {
                      context.push(
                        '/restaurant/dashboard/outlet/menu',
                        extra: ref.watch(authLocalRepositoryProvider).getUserData(),
                      );
                    },
                    child: Container(
                      clipBehavior: Clip.none,
                      margin: EdgeInsets.all(12),
                      width: screenWidth - 24,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0.1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FoodMenuItemViewWidget(restaurantMenu: menu),
                    ),
                  );
                }).toList(),
              );
            }, error: (error, stacktrace) {
              return Text("erorr");
            }, loading: () {
              return const Center(child: CircularProgressIndicator());
            }),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Posts", style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(width: 12),
                  Expanded(
                    child: Divider(
                      color: AppPallete.neutralColor,
                      thickness: 0.5,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: screenWidth,
              height: screenWidth * 0.7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: posts.when(
                  data: (data) {
                    if (!_hasSetInitialPage && data.posts.length > 2) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        carouselController.jumpTo(screenWidth * 0.1);
                      });
                      _hasSetInitialPage = true;
                    }

                    return CarouselView.weighted(
                      controller: carouselController,
                      itemSnapping: true,
                      padding: EdgeInsets.symmetric(horizontal: 3.0),
                      shrinkExtent: screenWidth * 0.1,
                      flexWeights: data.posts.length > 2 ? [1, 4, 1] : [1],
                      children: data.posts.map((post) => PostCarouselItem(post: post)).toList(),
                    );
                  },
                  error: (error, stacktrace) {
                    return CustomErrorWidget(
                      error: error.toString(),
                      title: "Posts items",
                      onPressed: () {
                        ref.invalidate(paginatePostsProvider(offset: 0, limit: 5));
                        FocusScope.of(context).focusedChild?.unfocus();
                      },
                    );
                  },
                  loading: () {
                    return SizedBox(
                      height: 300,
                      child: LoadingIndicatorWidget(),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Reviews", style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(width: 12),
                  Expanded(
                    child: Divider(
                      color: AppPallete.neutralColor,
                      thickness: 0.5,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
