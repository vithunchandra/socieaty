import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/core/utils/time_utils.dart';
import 'package:socieaty/features/food_menu/customer/view/outlet_food_menu_detail_widget.dart';
import 'package:socieaty/features/food_menu/customer/view/outlet_food_menu_item_widget.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/provider/get_all_food_menu_categories_provider.dart';
import 'package:socieaty/features/food_menu/provider/get_food_menu_provider.dart';
import 'package:socieaty/features/food_menu/provider/get_single_food_menu_provider.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/view/bottom_cart_widget.dart';
import 'package:socieaty/features/transaction_review/provider/get_all_restaurant_reviews_provider.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';

class OutletFoodMenuScreenArgs {
  final SocieatyRestaurant restaurant;
  final String? menuId;
  const OutletFoodMenuScreenArgs({required this.restaurant, this.menuId});
}

class OutletFoodMenuScreen extends ConsumerStatefulWidget {
  final OutletFoodMenuScreenArgs args;
  const OutletFoodMenuScreen({super.key, required this.args});

  @override
  ConsumerState<OutletFoodMenuScreen> createState() => _OutletFoodMenuScreenState();
}

class _OutletFoodMenuScreenState extends ConsumerState<OutletFoodMenuScreen> {
  String _locationName = "";
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  bool _isAlmostCollapsed = false;
  final GlobalKey _sliverKey = GlobalKey();
  double _sliverHeight = 0;
  late bool _isOpen;
  MenuFilterFormState _menuFilterFormState = MenuFilterFormState();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Duration _debounceDuration = const Duration(milliseconds: 500);
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isOpen = isNowBetween(widget.args.restaurant.restaurantData.openTime.toTimeOfDay(),
        widget.args.restaurant.restaurantData.closeTime.toTimeOfDay());
    getLocationName();
    _scrollController.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _measureSliverHeight();
      _showMenuDetailIfProvided();
    });
  }

  void _measureSliverHeight() {
    final RenderBox? renderBox = _sliverKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    if (size != null) {
      _sliverHeight = size.height;
    }
  }

  void _showMenuDetailIfProvided() {
    if (widget.args.menuId != null) {
      _showMenuDetail(widget.args.menuId!);
    }
  }

  void _showMenuDetail(String menuId) async {
    try {
      final menu = await ref.read(getSingleFoodMenuProvider(menuId).future);
      if (mounted) {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppPallete.neutralColor.shade50,
          enableDrag: true,
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => OutletFoodMenuDetailWidget(
            restaurantId: widget.args.restaurant.restaurantData.id,
            restaurantMenu: menu,
          ),
        );
      }
    } catch (e) {
      showSnackbar(null, "Failed to load menu: $e", state: SnackbarState.error);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void getLocationName() async {
    var location =
        await LocationHandler.getAddressFromLatLng(widget.args.restaurant.restaurantData.location);
    if (location != null && mounted) {
      setState(() {
        _locationName = "${location.street}";
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    double collapsedPercentage = _scrollController.offset / _sliverHeight;

    bool newIsAlmostCollapsed = collapsedPercentage >= 0.5;
    bool newIsCollapsed = collapsedPercentage >= 1;

    if (mounted && (newIsAlmostCollapsed != _isAlmostCollapsed || newIsCollapsed != _isCollapsed)) {
      setState(() {
        _isAlmostCollapsed = newIsAlmostCollapsed;
        _isCollapsed = newIsCollapsed;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(_debounceDuration, () {
      if (mounted && _menuFilterFormState.searchQuery != value) {
        setState(() {
          _menuFilterFormState = _menuFilterFormState.copyWith(searchQuery: value);
        });
      }
    });
  }

  void _updateCategories(List<int> newCategories) {
    if (!const ListEquality().equals(newCategories, _menuFilterFormState.categories)) {
      setState(() {
        _menuFilterFormState = _menuFilterFormState.copyWith(categories: newCategories);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantMenus = ref.watch(getFoodMenusProvider(
      restaurantId: widget.args.restaurant.restaurantData.id,
      query: _menuFilterFormState,
    ));

    final menuCategories = ref.watch(getAllFoodMenuCategoriesProvider);
    const isCartVisible = true;

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.neutralColor.shade50,
        surfaceTintColor: Colors.transparent,
        title: _isAlmostCollapsed ? Text(widget.args.restaurant.name) : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BottomCartWidget(
              restaurant: widget.args.restaurant,
              scrollController: _scrollController,
              onClick: (innerContext) {
                context.push("/${widget.args.restaurant.id}/shop/order",
                    extra: widget.args.restaurant);
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildHeaderSection(),
                  _buildCategoriesSection(menuCategories),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Menu", style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          DottedDivider(
                            color: AppPallete.neutralColor,
                            height: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildMenuItemsList(restaurantMenus),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 48),
                  ),
                  if (isCartVisible)
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    )
                ],
              ),
            ),
          ),
          _buildBottomSearchBar(),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Padding(
        key: _sliverKey,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.args.restaurant.name.toCapitalized(),
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: AppPallete.primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _locationName,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppPallete.primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                                "${_isOpen ? "Buka" : "Tutup"} | ${widget.args.restaurant.restaurantData.openTime} - ${widget.args.restaurant.restaurantData.closeTime}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildRatingWidget(),
              ],
            ),
            const SizedBox(height: 4),
            _buildThemesRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingWidget() {
    final reviewsAsync =
        ref.watch(getAllRestaurantReviewsProvider(widget.args.restaurant.restaurantData.id, null));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: PhysicalModel(
        color: AppPallete.neutralColor.shade50,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: reviewsAsync.when(
          data: (reviews) {
            final reviewCount = reviews.count;
            final averageRating = reviewCount > 0 ? reviews.rating : 0.0;

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 68,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      color: AppPallete.successColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            averageRating > 0 ? averageRating.toStringAsFixed(1) : "-",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$reviewCount",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            reviewCount == 1 ? "Review" : "Reviews",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => SizedBox(
            width: 68,
            height: 64,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: const LoadingIndicatorWidget(size: 20, color: Colors.white),
              ),
            ),
          ),
          error: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    color: AppPallete.successColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "-",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.star, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppPallete.errorColor,
                          size: 16,
                        ),
                        Text(
                          "Error",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: widget.args.restaurant.restaurantData.themes.map((theme) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Chip(
              backgroundColor: Colors.white,
              side: BorderSide(
                color: AppPallete.primaryColor.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              label: Text(
                theme.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPallete.primaryColor,
                    ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  SliverAppBar _buildCategoriesSection(AsyncValue<List<dynamic>> menuCategories) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: _isCollapsed ? AppPallete.neutralColor.shade50 : Colors.transparent,
      title: const Text(""),
      toolbarHeight: 60,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: _isCollapsed ? AppPallete.neutralColor.shade50 : Colors.white,
              boxShadow: _isCollapsed
                  ? []
                  : [
                      BoxShadow(
                        color: AppPallete.neutralColor.shade200,
                        blurRadius: 3,
                        spreadRadius: 0.1,
                        offset: const Offset(0, 0),
                      ),
                    ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    menuCategories.when(
                      data: (data) => Wrap(
                        spacing: 4,
                        children: data
                            .map((theme) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: FilterChip(
                                    label: Text(theme.name),
                                    selected: _menuFilterFormState.categories.contains(theme.id),
                                    onSelected: (bool selected) {
                                      final newCategories =
                                          List<int>.from(_menuFilterFormState.categories);
                                      if (selected) {
                                        newCategories.add(theme.id);
                                      } else {
                                        newCategories.remove(theme.id);
                                      }
                                      _updateCategories(newCategories);
                                    },
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Colors.white,
                                    selectedColor: AppPallete.primaryColor,
                                    checkmarkColor: Colors.white,
                                    showCheckmark: false,
                                    side: BorderSide(
                                      color: _menuFilterFormState.categories.contains(theme.id)
                                          ? AppPallete.primaryColor
                                          : AppPallete.neutralColor.shade300,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      error: (error, stacktrace) {
                        showSnackbar(context, error.toString(), state: SnackbarState.error);
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemsList(AsyncValue<List<FoodMenu>> restaurantMenus) {
    return switch (restaurantMenus) {
      AsyncData<List<FoodMenu>>(value: final data) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  if (index != 0) Divider(color: AppPallete.neutralColor, height: 0.5),
                  OutletFoodMenuItemWidget(
                    restaurantId: widget.args.restaurant.id,
                    restaurantMenu: data[index],
                  ),
                ],
              );
            },
          ),
        ),
      AsyncError(:final error) => SliverToBoxAdapter(
          child: CustomErrorWidget(
            title: "Item Menu",
            error: error.toString(),
            onPressed: () => ref.invalidate(getFoodMenusProvider(
              restaurantId: widget.args.restaurant.restaurantData.id,
              query: _menuFilterFormState,
            )),
          ),
        ),
      _ => const SliverToBoxAdapter(
          child: LoadingIndicatorWidget(size: 36),
        ),
    };
  }

  Widget _buildBottomSearchBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppPallete.neutralColor.shade50,
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor,
            blurRadius: 12.0,
            spreadRadius: 0.1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  autofocus: false,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
                    hintText: "Search",
                    hintStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            SizedBox(
              height: 45,
              child: FilledButton(
                onPressed: () {
                  FocusScope.of(context).focusedChild?.unfocus();
                  showFilterBottomSheet(context, _menuFilterFormState).then(
                    (value) {
                      if (value != null && mounted) {
                        setState(() {
                          _menuFilterFormState = value;
                        });
                      }
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(children: [
                    const Icon(
                      Icons.tune,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Filter",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const Icon(Icons.arrow_drop_up, size: 20, color: Colors.white),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
