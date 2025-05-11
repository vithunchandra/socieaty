import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/core/utils/time_utils.dart';
import 'package:socieaty/features/food_menu/customer/view/outlet_food_menu_item_widget.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/model/menu_cart.dart';
import 'package:socieaty/features/food_menu/provider/get_all_food_menu_categories_provider.dart';
import 'package:socieaty/features/food_menu/provider/get_food_menu_provider.dart';
import 'package:socieaty/features/food_menu/provider/menu_cart_view_model.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/view/bottom_cart_widget.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';

class ReservationFoodSelectionScreenArgs {
  final SocieatyRestaurant restaurant;
  const ReservationFoodSelectionScreenArgs({required this.restaurant});
}

class ReservationFoodSelectionScreenResult {
  final List<MenuCart> menuItems;
  const ReservationFoodSelectionScreenResult({required this.menuItems});
}

class ReservationFoodSelectionScreen extends ConsumerStatefulWidget {
  final ReservationFoodSelectionScreenArgs args;
  const ReservationFoodSelectionScreen({super.key, required this.args});

  @override
  ConsumerState<ReservationFoodSelectionScreen> createState() =>
      _ReservationFoodSelectionScreenState();
}

class _ReservationFoodSelectionScreenState extends ConsumerState<ReservationFoodSelectionScreen> {
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
    _scrollController.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _measureSliverHeight();
    });
  }

  void _measureSliverHeight() {
    final RenderBox? renderBox = _sliverKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    if (size != null) {
      _sliverHeight = size.height;
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
        title: Text('Pilih Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final menuItems =
                ref.watch(menuCartViewModelProvider(widget.args.restaurant.id)).menuItems;
            context.pop(ReservationFoodSelectionScreenResult(menuItems: menuItems));
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BottomCartWidget(
              restaurant: widget.args.restaurant,
              scrollController: _scrollController,
              onClick: (innerContext) {
                final menuItems =
                    ref.watch(menuCartViewModelProvider(widget.args.restaurant.id)).menuItems;
                return context.pop(ReservationFoodSelectionScreenResult(menuItems: menuItems));
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
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tambahkan menu ke reservasi Anda", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              "Pilih menu yang Anda inginkan untuk reservasi di ${widget.args.restaurant.name.toCapitalized()}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPallete.neutralColor.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppPallete.primaryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppPallete.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Menu yang dipilih akan ditambahkan ke reservasi Anda. Anda dapat mengubahnya nanti.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPallete.primaryColor,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            title: "Item menu",
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
                    hintText: "Cari",
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
