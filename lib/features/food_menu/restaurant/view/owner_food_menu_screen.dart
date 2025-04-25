import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/core/utils/time_utils.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/provider/get_all_food_menu_categories_provider.dart';
import 'package:socieaty/features/food_menu/provider/get_food_menu_provider.dart';
import 'package:socieaty/features/food_menu/provider/get_single_food_menu_provider.dart';
import 'package:socieaty/features/food_menu/restaurant/view/owner_food_menu_detail_widget.dart';
import 'package:socieaty/features/food_menu/restaurant/view/owner_food_menu_item_widget.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';

class OwnerFoodMenuScreenArgs {
  final SocieatyRestaurant restaurant;
  final String? menuId;
  const OwnerFoodMenuScreenArgs({required this.restaurant, this.menuId});
}

class OwnerFoodMenuScreen extends ConsumerStatefulWidget {
  final OwnerFoodMenuScreenArgs args;
  const OwnerFoodMenuScreen({super.key, required this.args});

  @override
  ConsumerState<OwnerFoodMenuScreen> createState() => _OwnerFoodMenuScreenState();
}

class _OwnerFoodMenuScreenState extends ConsumerState<OwnerFoodMenuScreen> {
  String _locationName = "";
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  bool _isAlmostCollapsed = false;
  final GlobalKey _sliverKey = GlobalKey();
  double _sliverHeight = 0;
  bool _isOpen = false;
  MenuFilterFormState _menuFilterFormState = MenuFilterFormState();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Duration _debounceDuration = Duration(milliseconds: 500);
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getLocationName();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _sliverKey.currentContext?.findRenderObject() as RenderBox?;
      final size = renderBox?.size;
      if (size != null) {
        _sliverHeight = size.height;
      }

      // Show menu detail if menuId is provided
      if (widget.args.menuId != null) {
        _showMenuDetail(widget.args.menuId!);
      }
    });
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
          builder: (context) => OwnerFoodMenuDetailWidget(
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
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void getLocationName() async {
    var location =
        await LocationHandler.getAddressFromLatLng(widget.args.restaurant.restaurantData.location);
    _locationName = "${location?.street}";
    if (mounted) {
      setState(() {});
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    double collapsedPercentage = _scrollController.offset / _sliverHeight;

    if (mounted) {
      if (collapsedPercentage >= 0.5 && !_isAlmostCollapsed) {
        setState(() {
          _isAlmostCollapsed = true;
        });
      } else if (collapsedPercentage < 0.5 && _isAlmostCollapsed) {
        setState(() {
          _isAlmostCollapsed = false;
        });
      }
      if (collapsedPercentage >= 1 && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (collapsedPercentage < 1 && _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(_debounceDuration, () {
      _menuFilterFormState = _menuFilterFormState.copyWith(searchQuery: value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantMenus = ref.watch(getFoodMenusProvider(
      restaurantId: widget.args.restaurant.restaurantData.id,
      query: _menuFilterFormState,
    ));

    _isOpen = isNowBetween(widget.args.restaurant.restaurantData.openTime.toTimeOfDay(),
        widget.args.restaurant.restaurantData.closeTime.toTimeOfDay());

    final menuCategories = ref.watch(getAllFoodMenuCategoriesProvider);

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
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
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
                                        Icon(Icons.location_on,
                                            color: AppPallete.primaryColor, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(_locationName,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppPallete.primaryColor,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white, size: 16),
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
                              SizedBox(width: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: PhysicalModel(
                                  color: AppPallete.neutralColor.shade50,
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(12),
                                  child: ClipRRect(
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
                                                  "4.6",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
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
                                                  "9403",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  "Reviews",
                                                  style: Theme.of(context).textTheme.bodyMedium,
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
                            ],
                          ),
                          const SizedBox(height: 4),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ...widget.args.restaurant.restaurantData.themes.map((theme) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Chip(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: AppPallete.primaryColor.withOpacity(0.3),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)),
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      label: Text(
                                        theme.name,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppPallete.primaryColor,
                                            ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor:
                        _isCollapsed ? AppPallete.neutralColor.shade50 : Colors.transparent,
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
                                  GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).focusedChild?.unfocus();
                                      showFilterBottomSheet(context, _menuFilterFormState).then(
                                        (value) {
                                          if (value != null) {
                                            _menuFilterFormState = value;
                                            setState(() {});
                                          }
                                        },
                                      );
                                    },
                                    child: Chip(
                                      label: Row(children: [
                                        Icon(
                                          Icons.tune,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Filters",
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
                                      ]),
                                      side: BorderSide(color: AppPallete.primaryColor, width: 1),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: AppPallete.primaryColor,
                                      labelStyle: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  menuCategories.when(
                                    data: (data) => Wrap(
                                      spacing: 4,
                                      children: data
                                          .map((theme) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                                child: FilterChip(
                                                  label: Text(theme.name),
                                                  selected: _menuFilterFormState.categories
                                                      .contains(theme.id),
                                                  onSelected: (bool selected) {
                                                    setState(() {
                                                      final newCategories = List<int>.from(
                                                          _menuFilterFormState.categories);
                                                      if (selected) {
                                                        newCategories.add(theme.id);
                                                      } else {
                                                        newCategories.remove(theme.id);
                                                      }
                                                      _menuFilterFormState =
                                                          _menuFilterFormState.copyWith(
                                                        categories: newCategories,
                                                      );
                                                    });
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  backgroundColor: Colors.white,
                                                  selectedColor: AppPallete.primaryColor,
                                                  checkmarkColor: Colors.white,
                                                  showCheckmark: false,
                                                  side: BorderSide(
                                                    color: _menuFilterFormState.categories
                                                            .contains(theme.id)
                                                        ? AppPallete.primaryColor
                                                        : AppPallete.neutralColor.shade300,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                    error: (error, stacktrace) {
                                      showSnackbar(context, error.toString(),
                                          state: SnackbarState.error);
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
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Menu", style: Theme.of(context).textTheme.titleLarge),
                          SizedBox(height: 8),
                          DottedDivider(
                            color: AppPallete.neutralColor,
                            height: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  switch (restaurantMenus) {
                    AsyncData<List<FoodMenu>>(value: final data) => SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                if (index != 0)
                                  Divider(color: AppPallete.neutralColor, height: 0.5),
                                OwnerFoodMenuItemWidget(
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
                          title: "Menu items",
                          error: error.toString(),
                          onPressed: () {
                            ref.invalidate(getFoodMenusProvider(
                              restaurantId: widget.args.restaurant.restaurantData.id,
                              query: _menuFilterFormState,
                            ));
                          },
                        ),
                      ),
                    _ => const SliverToBoxAdapter(
                        child: LoadingIndicatorWidget(size: 36),
                      ),
                  },
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 48),
                  )
                ],
              ),
            ),
            Container(
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
                        onChanged: (value) {
                          _onSearchChanged(value);
                        },
                        autofocus: false,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
                          hintText: "Search",
                          hintStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )),
                    SizedBox(width: 8.0),
                    SizedBox(
                      height: 45,
                      child: FilledButton(
                        onPressed: () {
                          context.push("/restaurant/dashboard/outlet/menu/create");
                          FocusScope.of(context).focusedChild?.unfocus();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text("Add Menu"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
