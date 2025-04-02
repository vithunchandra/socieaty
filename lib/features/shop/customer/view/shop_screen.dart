import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food_menu/customer/view/food_menu_highlight_item_widget.dart';
import 'package:socieaty/features/food_menu/model/menu_category.dart';
import 'package:socieaty/features/food_menu/provider/get_all_food_menu_categories_provider.dart';
import 'package:socieaty/features/food_menu/provider/paginate_menu_provider.dart';
import 'package:socieaty/features/food_menu/restaurant/viewstate/paginate_menu_form_state.dart';
import 'package:socieaty/features/restaurant/provider/paginate_restaurant_provider.dart';
import 'package:socieaty/features/restaurant/view/outlet_card_widget.dart';
import 'package:socieaty/features/restaurant/view/restaurant_highlight_item_widget.dart';
import 'package:socieaty/features/restaurant/viewstate/paginate_restaurant_query_state.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';
import 'package:socieaty/shared/widgets/search_bar_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final SearchController _searchController = SearchController();
  List<MenuCategory> _menuCategories = [];
  MenuFilterFormState _menuFilterFormState = MenuFilterFormState();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(getAllFoodMenuCategoriesProvider, (_, next) {
      switch (next) {
        case AsyncData<List<MenuCategory>>(value: final data):
          _menuCategories = data;
        case AsyncError<List<MenuCategory>>(error: final error):
          showSnackbar(context, error.toString(), state: SnackbarState.error);
        default:
      }
      setState(() {});
    });

    final restaurantMenus = ref.watch(paginateMenuProvider(
      PaginateMenuFormState(
        offset: 0,
        limit: 5,
      ),
    ));

    final restaurantHighlights = ref.watch(paginateRestaurantProvider(
      PaginateRestaurantQueryState(
        offset: 0,
        limit: 5,
      ),
    ));

    final paginateOutlet = ref.watch(paginateRestaurantProvider(
      PaginateRestaurantQueryState(
        offset: 0,
        limit: 20,
      ),
    ));

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: _ShopDetailsHeader(),
              ),
              SliverAppBar(
                pinned: true,
                backgroundColor: AppPallete.neutralColor.shade50,
                surfaceTintColor: AppPallete.neutralColor.shade50,
                automaticallyImplyLeading: false,
                toolbarHeight: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52 + 48 + 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SearchBarWidget(
                          hintText: "Cari restoran atau makanan",
                          onTap: () {
                            context.push('/customer/shop/search');
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ..._menuCategories.map(
                                (category) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: FilterChip(
                                    label: Text(category.name),
                                    selected: _menuFilterFormState.categories.contains(category.id),
                                    onSelected: (bool selected) {
                                      setState(() {
                                        final newCategories =
                                            List<int>.from(_menuFilterFormState.categories);
                                        if (selected) {
                                          newCategories.add(category.id);
                                        } else {
                                          newCategories.remove(category.id);
                                        }
                                        _menuFilterFormState = _menuFilterFormState.copyWith(
                                            categories: newCategories);
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Colors.white,
                                    selectedColor: Theme.of(context).primaryColor,
                                    checkmarkColor: Colors.white,
                                    showCheckmark: false,
                                    side: BorderSide(
                                      color: _menuFilterFormState.categories.contains(category.id)
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Restaurant populer dekatmu",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: restaurantHighlights.when(data: (data) {
                  final partialData = data.restaurants;
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
                    items: partialData.map((restaurant) {
                      return GestureDetector(
                        onTap: () {
                          context.push('/${restaurant.id}');
                        },
                        child: SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: RestaurantHighlightItemWidget(restaurant: restaurant),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }, error: (error, stacktrace) {
                  return CustomErrorWidget(
                    error: error.toString(),
                    title: "Error",
                    onPressed: () {
                      ref.invalidate(getAllFoodMenuCategoriesProvider);
                    },
                  );
                }, loading: () {
                  return const LoadingIndicatorWidget(size: 36);
                }),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Menu populer dekatmu",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: restaurantMenus.when(
                  data: (data) {
                    final partialData = data.menus;
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
                          onTap: () {},
                          child: Container(
                            clipBehavior: Clip.none,
                            margin: const EdgeInsets.all(12),
                            width: MediaQuery.of(context).size.width - 24,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 0.1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {},
                              child: FoodMenuHighlightItemWidget(restaurantMenu: menu),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  error: (error, stacktrace) {
                    return CustomErrorWidget(
                      error: error.toString(),
                      title: "Error",
                      onPressed: () {
                        ref.invalidate(getAllFoodMenuCategoriesProvider);
                      },
                    );
                  },
                  loading: () => const LoadingIndicatorWidget(size: 36),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              paginateOutlet.when(
                data: (data) {
                  final restaurants = data.restaurants;
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return GestureDetector(
                          onTap: () {
                            context.push('/${restaurants[index].id}');
                          },
                          child: OutletCardWidget(
                            restaurant: restaurants[index],
                          ),
                        );
                      },
                      childCount: restaurants.length,
                    ),
                  );
                },
                error: (error, stacktrace) {
                  return SliverToBoxAdapter(
                    child: CustomErrorWidget(
                      error: error.toString(),
                      title: "Error",
                      onPressed: () {
                        ref.invalidate(paginateRestaurantProvider(
                          PaginateRestaurantQueryState(
                            offset: 0,
                            limit: 20,
                          ),
                        ));
                      },
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(child: const LoadingIndicatorWidget(size: 36)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopDetailsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vasanth Nagar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Bengaluru',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(Icons.history, color: AppPallete.primaryColor, size: 28),
              items: [
                DropdownMenuItem(
                  value: 'order',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_outlined, color: AppPallete.neutralColor.shade800),
                      const SizedBox(width: 10),
                      Text('Order', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'reservation',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: AppPallete.neutralColor.shade800),
                      const SizedBox(width: 10),
                      Text('Reservation', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                switch (value) {
                  case 'order':
                    context.push('/customer/shop/history/order');
                    break;
                  case 'reservation':
                    context.push('/customer/shop/history/reservation');
                    break;
                }
              },
              dropdownStyleData: DropdownStyleData(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                offset: const Offset(0, 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
