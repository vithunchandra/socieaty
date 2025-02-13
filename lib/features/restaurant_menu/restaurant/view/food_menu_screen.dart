import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/core/utils/time_utils.dart';
import 'package:socieaty/features/restaurant_menu/model/menu_category.dart';
import 'package:socieaty/features/restaurant_menu/model/food_menu.dart';
import 'package:socieaty/features/restaurant_menu/provider/get_all_food_menu_categories_provider.dart';
import 'package:socieaty/features/restaurant_menu/provider/get_food_menu_provider.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/view/food_menu_item_widget.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';

class FoodMenuScreen extends ConsumerStatefulWidget {
  final SocieatyUser restaurant;
  const FoodMenuScreen({super.key, required this.restaurant});

  @override
  ConsumerState<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends ConsumerState<FoodMenuScreen> {
  String _locationName = "";
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  bool _isAlmostCollapsed = false;
  final GlobalKey _sliverKey = GlobalKey();
  double _sliverHeight = 0;
  bool _isOpen = false;
  List<MenuCategory> _menuCategories = [];
  MenuFilterFormState _menuFilterFormState = MenuFilterFormState();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Duration _debounceDuration = Duration(milliseconds: 500);
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    getLocationName();
    _scrollController.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _sliverKey.currentContext?.findRenderObject() as RenderBox?;
      final size = renderBox?.size;
      if (size != null) {
        _sliverHeight = size.height;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void getLocationName() async {
    if (widget.restaurant.restaurantData?.location != null) {
      var location =
          await LocationHandler.getAddressFromLatLng(widget.restaurant.restaurantData!.location);
      _locationName = "${location?.street}";
      if (mounted) {
        setState(() {});
      }
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
    final restaurantMenus = ref.watch(getFoodMenusProvider(_menuFilterFormState));

    _isOpen = isNowBetween(widget.restaurant.restaurantData?.openTime.toTimeOfDay(),
        widget.restaurant.restaurantData?.closeTime.toTimeOfDay());

    ref.listen(getAllFoodMenuCategoriesProvider, (_, next) {
      switch (next) {
        case AsyncData<List<MenuCategory>>(value: final data):
          debugPrint('data: $data');
          _menuCategories = data;
        case AsyncError<List<MenuCategory>>(error: final error):
          showSnackbar(context, error.toString(), isError: true);
        default:
      }
      setState(() {});
    });

    return Scaffold(
        backgroundColor: AppPallete.neutralColor.shade50,
        appBar: AppBar(
          backgroundColor: AppPallete.neutralColor.shade50,
          surfaceTintColor: Colors.transparent,
          title: _isAlmostCollapsed ? Text(widget.restaurant.name) : null,
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
                                    Text(widget.restaurant.name.toCapitalized(),
                                        style: Theme.of(context).textTheme.headlineMedium),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: AppPallete.primaryColor, size: 16),
                                        const SizedBox(width: 4),
                                        Text(_locationName,
                                            style: Theme.of(context).textTheme.bodyMedium),
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
                                              "${_isOpen ? "Buka" : "Tutup"} | ${widget.restaurant.restaurantData?.openTime} - ${widget.restaurant.restaurantData?.closeTime}",
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
                                ...widget.restaurant.restaurantData?.themes.map((theme) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Chip(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color: AppPallete.primaryColor.withOpacity(0.3),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          label: Text(
                                            theme.name,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: AppPallete.primaryColor,
                                                ),
                                          ),
                                        ),
                                      );
                                    }).toList() ??
                                    [],
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
                                  ..._menuCategories.map(
                                    (theme) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                      child: FilterChip(
                                        label: Text(theme.name),
                                        selected:
                                            _menuFilterFormState.categories.contains(theme.id),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            final newCategories =
                                                List<int>.from(_menuFilterFormState.categories);
                                            if (selected) {
                                              newCategories.add(theme.id);
                                            } else {
                                              newCategories.remove(theme.id);
                                            }
                                            _menuFilterFormState = _menuFilterFormState.copyWith(
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
                                          color: _menuFilterFormState.categories.contains(theme.id)
                                              ? AppPallete.primaryColor
                                              : AppPallete.neutralColor.shade300,
                                        ),
                                      ),
                                    ),
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
                                FoodMenuItemWidget(
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
                            ref.invalidate(getFoodMenusProvider(_menuFilterFormState));
                          },
                        ),
                      ),
                    _ => const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
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

  IconData _getThemeIcon(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'italian':
        return Icons.local_pizza;
      case 'japanese':
        return Icons.ramen_dining;
      case 'chinese':
        return Icons.rice_bowl;
      case 'indian':
        return Icons.dinner_dining;
      case 'vegetarian':
        return Icons.eco;
      case 'seafood':
        return Icons.set_meal;
      case 'fast food':
        return Icons.fastfood;
      case 'dessert':
        return Icons.cake;
      case 'drinks':
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }
}
