import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';
import 'package:socieaty/features/restaurant_menu/provider/get_restaurant_menu_provider.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewmodel/restaurant_menu_detail_widget_view_model.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewmodel/restaurant_menu_item_widget_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/delete_confirmation_dialog.dart';

class RestaurantMenuDetailWidget extends ConsumerStatefulWidget {
  final RestaurantMenu restaurantMenu;
  const RestaurantMenuDetailWidget({super.key, required this.restaurantMenu});

  @override
  ConsumerState<RestaurantMenuDetailWidget> createState() => _RestaurantMenuDetailWidgetState();
}

class _RestaurantMenuDetailWidgetState extends ConsumerState<RestaurantMenuDetailWidget> {
  late RestaurantMenu _menu;
  bool _isAvailable = false;
  Timer? _debounce;
  final Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    debugPrint('menu: ${widget.restaurantMenu}');
    _menu = widget.restaurantMenu;
    _isAvailable = _menu.isStockAvailable;
  }

  @override
  void didUpdateWidget(RestaurantMenuDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurantMenu.id != widget.restaurantMenu.id) {
      _menu = widget.restaurantMenu;
      _isAvailable = _menu.isStockAvailable;
    }
  }

  _onSwitch() {
    setState(() {
      _isAvailable = !_isAvailable;
    });
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(_debounceDuration, () {
      ref
          .read(restaurantMenuDetailWidgetViewModelProvider(_menu.id).notifier)
          .updateMenuStock(_menu.id, _isAvailable);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDeleting = ref
        .watch(restaurantMenuDetailWidgetViewModelProvider(_menu.id))
        .deletedMenuMessage is LoadingState;

    ref.listen(restaurantMenuDetailWidgetViewModelProvider(_menu.id), (_, next) {
      switch (next.updatedMenu) {
        case SuccessState(data: final data):
          _menu = data;
          ref.watch(restaurantMenuItemWidgetViewModelProvider(_menu.id).notifier).updateMenu(_menu);
          setState(() {});
        case ErrorState(message: final message):
          showSnackbar(context, message, isError: true);
        case LoadingState():
        case IdleState():
      }

      switch (next.deletedMenuMessage) {
        case SuccessState():
          ref.invalidate(getRestaurantMenusProvider);
          ref.invalidate(restaurantMenuItemWidgetViewModelProvider(_menu.id));
          ref.invalidate(restaurantMenuDetailWidgetViewModelProvider(_menu.id));
          context.pop();
        case ErrorState(message: final message):
          showSnackbar(context, message, isError: true);
        case LoadingState():
        case IdleState():
      }
    });

    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.8,
      child: Column(
        children: [
          // Drag indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    Hero(
                      tag: widget.restaurantMenu.id,
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.restaurantMenu.pictureUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              return imageLoadingWidget(context, child, loadingProgress);
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return imageErrorWidget(context, error, stackTrace);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Menu information
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.restaurantMenu.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${widget.restaurantMenu.estimatedTime} menit",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${widget.restaurantMenu.price.toIDRFormat()}",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Categories with Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...widget.restaurantMenu.categories.map((category) {
                          return Chip(
                            label: Text(
                              category.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppPallete.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            backgroundColor: AppPallete.primaryColor.shade200.withOpacity(0.1),
                            side: BorderSide(
                              color: AppPallete.primaryColor.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: -2,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        })
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      "Description",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.restaurantMenu.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppPallete.neutralColor.shade500,
                            height: 1.5,
                          ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 0.1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.restaurantMenu.isStockAvailable
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Menu Availability",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isAvailable,
                            activeColor: AppPallete.primaryColor,
                            thumbIcon: WidgetStateProperty.all(
                              _isAvailable ? const Icon(Icons.check) : const Icon(Icons.close),
                            ),
                            inactiveThumbColor: AppPallete.errorColor,
                            onChanged: (bool value) {
                              _onSwitch();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteConfirmationDialog(
                          title: _menu.name,
                          contentType: 'Menu',
                          onDelete: () {
                            Navigator.pop(context);
                            ref
                                .read(
                                    restaurantMenuDetailWidgetViewModelProvider(_menu.id).notifier)
                                .deleteMenu();
                          },
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPallete.errorColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: LoadingIndicatorWidget(),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Delete"),
                              SizedBox(width: 8),
                              Icon(Icons.delete_outline, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      context.push(
                        '/restaurant/dashboard/outlet/menu/update',
                        extra: _menu,
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Edit"),
                        SizedBox(width: 8),
                        Icon(Icons.edit_outlined, size: 20)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
