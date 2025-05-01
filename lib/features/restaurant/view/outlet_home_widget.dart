import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/food_menu/customer/view/food_menu_highlight_item_widget.dart';
import 'package:socieaty/features/post/post/provider/paginate_posts_provider.dart';
import 'package:socieaty/features/post/post/repository/request/paginate_post_query.dart';
import 'package:socieaty/features/post/post/view/post_carousel_item_widget.dart';
import 'package:socieaty/features/food_menu/provider/get_food_menu_provider.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';

class OutletHomeWidget extends ConsumerStatefulWidget {
  final SocieatyRestaurant restaurant;
  final Function(String) onMenuCarouselItemTapped;
  final VoidCallback onPostCarouselItemTapped;
  final VoidCallback onReviewCarouselItemTapped;
  const OutletHomeWidget({
    super.key,
    required this.onMenuCarouselItemTapped,
    required this.onPostCarouselItemTapped,
    required this.onReviewCarouselItemTapped,
    required this.restaurant,
  });

  @override
  ConsumerState<OutletHomeWidget> createState() => _OutletHomeWidgetState();
}

class _OutletHomeWidgetState extends ConsumerState<OutletHomeWidget> {
  final carouselController = CarouselController();
  bool _hasSetInitialPage = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final restaurantMenus = ref.watch(getFoodMenusProvider(
      restaurantId: widget.restaurant.restaurantData.id,
      query: MenuFilterFormState(),
    ));
    final posts = ref.watch(
      paginatePostsProvider(PaginatePostQuery(
        paginationQuery: PaginationQuery(page: 0, pageSize: 5),
        authorId: widget.restaurant.id,
      )),
    );

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
              if (data.isEmpty) {
                return _buildEmptyMenuState(context, screenWidth);
              }

              final carouselLength = data.length > 5 ? 5 : data.length;
              final partialData = data.take(carouselLength).toList();

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
                      widget.onMenuCarouselItemTapped(menu.id);
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
                      child: FoodMenuHighlightItemWidget(restaurantMenu: menu),
                    ),
                  );
                }).toList(),
              );
            }, error: (error, stacktrace) {
              return Text("erorr");
            }, loading: () {
              return const LoadingIndicatorWidget(size: 36);
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
                    if (data.posts.isEmpty) {
                      return _buildEmptyPostsState(context);
                    }

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
                      onTap: (index) {
                        widget.onPostCarouselItemTapped();
                      },
                      shrinkExtent: screenWidth * 0.1,
                      flexWeights: data.posts.length > 2 ? [1, 4, 1] : [1],
                      children:
                          data.posts.map((post) => PostCarouselItemWidget(post: post)).toList(),
                    );
                  },
                  error: (error, stacktrace) {
                    return CustomErrorWidget(
                      error: error.toString(),
                      title: "Posts items",
                      onPressed: () {
                        ref.invalidate(
                          paginatePostsProvider(PaginatePostQuery()),
                        );
                        FocusScope.of(context).focusedChild?.unfocus();
                      },
                    );
                  },
                  loading: () {
                    return const LoadingIndicatorWidget(size: 36);
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

  Widget _buildEmptyMenuState(BuildContext context, double screenWidth) {
    return Container(
      clipBehavior: Clip.none,
      margin: EdgeInsets.all(12),
      width: screenWidth - 24,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            spreadRadius: 0.1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48,
              color: AppPallete.neutralColor[300],
            ),
            SizedBox(height: 16),
            Text(
              "No menu items available",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppPallete.neutralColor[500],
                  ),
            ),
            SizedBox(height: 8),
            Text(
              "This restaurant hasn't added any menu items yet",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPallete.neutralColor[400],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPostsState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            spreadRadius: 0.1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 48,
              color: AppPallete.neutralColor[300],
            ),
            SizedBox(height: 16),
            Text(
              "No posts available",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppPallete.neutralColor[500],
                  ),
            ),
            SizedBox(height: 8),
            Text(
              "This restaurant hasn't shared any posts yet",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPallete.neutralColor[400],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
